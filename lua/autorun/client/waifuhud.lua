waifuhud = waifuhud or {}

waifuhud.folder = "waifuhud/"

waifuhud.files = {
    "miku_facecheck_v2.png",
    "miku_hooked_v2.png",
    "teto_facecheck_v2.png",
    "teto_hooked_v2.png",
    "sylphiette_hooked.png",
    "roxy_hooked.png",
    "eris_hooked.png",
}

waifuhud.colors = {
    Color( 134, 211, 225, 255 ),
    Color( 134, 211, 225, 255 ),
    Color( 255, 103, 131, 255 ),
    Color( 255, 103, 131, 255 ),
    Color( 249, 234, 227, 255 ),
    Color( 114, 129, 210, 255 ),
    Color( 254, 68, 52, 255 ),
}

waifuhud.cv_enabled = CreateConVar( "waifuhud_enabled", 1, FCVAR_ARCHIVE, "Waifuhud enabled", 0, 1 )
waifuhud.cv_left = CreateConVar( "waifuhud_left", 1, FCVAR_ARCHIVE, "Waifu ont the left", 0, #waifuhud.files )
waifuhud.cv_right = CreateConVar( "waifuhud_right", 3, FCVAR_ARCHIVE, "Waifu on the right", 0, #waifuhud.files )
waifuhud.cv_size = CreateConVar( "waifuhud_size", 330, FCVAR_ARCHIVE, "Waifu size", 0, 512 )
waifuhud.cv_customhud = CreateConVar( "waifuhud_customhud", 1, FCVAR_ARCHIVE, "Waifuhud custom hud", 0, 1 )

waifuhud.color_left = waifuhud.colors[ waifuhud.cv_left:GetInt() ] or waifuhud.colors[ 1 ]
waifuhud.color_right = waifuhud.colors[ waifuhud.cv_right:GetInt() ] or waifuhud.colors[ 1 ]


-- Всякое для рендера
local sw, sh, size

surface.CreateFont( "waifuhudBigGlow", {
    font = "Consolas",
	extended = true,
	size = 56,
	weight = 600,
	blursize = 6,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "waifuhudBig", {
    font = "Consolas",
	extended = true,
	size = 56,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "waifuhudMediumGlow", {
    font = "Consolas",
	extended = true,
	size = 30,
	weight = 600,
	blursize = 6,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "waifuhudMedium", {
    font = "Consolas",
	extended = true,
	size = 30,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "waifuhudSmallGlow", {
    font = "Consolas",
	extended = true,
	size = 15,
	weight = 600,
	blursize = 6,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "waifuhudSmall", {
    font = "Consolas",
	extended = true,
	size = 15,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )


-- Локализация шлака
local math_max = math.max
local math_min = math.min
local draw_SimpleText = draw.SimpleText
local AmmoTypes

-- ХТМЛ
local htmlcode = [[
<head>
    <meta charset="utf-8">
    <style>
        html, body {
            margin: 0; padding: 0; overflow: hidden;
            background: transparent; width: 100%; height: 100%;
        }
        img {
            width: 100%;
            height: 100%;
            transform: scaleX( #GIFMIRROR# );
            object-fit: contain;
            display: block;
        }
    </style>
</head>
<body>
    <img id="gif" src="asset://garrysmod/data/#GIFPATH#" />
</body>
]]


waifuhud.switch = function()
    if waifuhud.cv_enabled:GetBool() then
        waifuhud.initialize()
    else
        if waifuhud.left then waifuhud.left:Remove() end
        if waifuhud.right then waifuhud.right:Remove() end

        hook.Remove( "OnScreenSizeChanged", "waifuhud:resolution" )
        hook.Remove( "HUDPaint", "waifuhud:hud" )
        hook.Remove( "HUDShouldDraw", "waifuhud:hide" )
    end
end

waifuhud.changed = function( name )
    if not waifuhud.cv_enabled:GetBool() then return end

    val = GetConVarNumber( name )

    if name == "waifuhud_size" then
        sw = ScrW()
        sh = ScrH()
        size = val

        if waifuhud.left then
            waifuhud.left:SetSize( size, size )
            waifuhud.left:SetPos( -1, sh - size + 1 )
        end

        if waifuhud.right then
            waifuhud.right:SetSize( size, size )
            waifuhud.right:SetPos( sw - size + 1, sh - size + 1 )
        end

        return
    end

    local index = name:gsub( "waifuhud_", "" )
    if index ~= "left" and index ~= "right" then return end
    if not waifuhud[ index ] then return end

    if waifuhud[ "dtextentry_" .. index ] then
        waifuhud[ "dtextentry_" .. index ]:SetText( waifuhud.files[ val ] or "hidden" )
    end

    if val == 0 then
        waifuhud[ index ]:Hide()
        return
    end

    if not waifuhud.files[ val ] then return end

    waifuhud[ index ]:Show()
    waifuhud[ index ]:SetHTML( htmlcode:gsub( "#GIFMIRROR#", index == "left" and "-1" or "1" ):gsub( "#GIFPATH#", waifuhud.folder .. waifuhud.files[ val ] ) )

    waifuhud[ "color_" .. index ] = waifuhud.colors[ val ]
end

waifuhud.initialize = function()
    if not waifuhud.cv_enabled:GetBool() then
        print( "[waifuhud] is disabled" )
        return
    end

    AmmoTypes = game.GetAmmoTypes()

    -- Создание папки, если её не существует
    if not file.Exists( waifuhud.folder, "DATA" ) then
        file.CreateDir( waifuhud.folder )
    end

    -- Если аддон обновляется, могу обновится гифки -> удаляем старые
    local files, _ = file.Find( waifuhud.folder .. "*.png", "DATA" )
    for _, filename in ipairs( files ) do
        if not table.HasValue( waifuhud.files, filename ) then
            file.Delete( waifuhud.folder .. filename, "DATA" )
            print( "[waifuhud] File " .. filename .. " was deleted" )
        end
    end

    -- Копируем девчонок в data, если их там нет
    for _, name in ipairs( waifuhud.files ) do
        local path = waifuhud.folder .. name
        if file.Exists( path, "DATA" ) then continue end

        local content = file.Read( "data_static/" .. name:gsub( ".png", ".dat" ), "GAME" )

        if content then
            file.Write( path, content )
            print( "[waifuhud] " .. path .. " saved to user data" )
        else
            print( "[waifuhud] ERROR: Failed to read the file " .. name )
        end
    end

    -- Удаляем старые DHTML, если таковые имеются
    if waifuhud.left then waifuhud.left:Remove() end
    if waifuhud.right then waifuhud.right:Remove() end

    -- Лимит размера 512px, т.к. это размер гифок, а мы не хотим мыла фу
    size = math.min( 512, GetConVarNumber( "waifuhud_size" ) )

    sw = ScrW()
    sh = ScrH()

    -- Создание DHTML
    local indexleft = GetConVarNumber( "waifuhud_left" )
    local indexright = GetConVarNumber( "waifuhud_right" )
    
    waifuhud.left = vgui.Create( "DHTML" )
    waifuhud.left:SetMouseInputEnabled( false )
    waifuhud.left:SetKeyboardInputEnabled( false )
    waifuhud.left:SetSize( size, size )
    waifuhud.left:SetPos( -1, sh - size + 1 )

    waifuhud.right = vgui.Create( "DHTML" )
    waifuhud.right:SetMouseInputEnabled( false )
    waifuhud.right:SetKeyboardInputEnabled( false )
    waifuhud.right:SetSize( size, size )
    waifuhud.right:SetPos( sw - size + 1, sh - size + 1 )

    if indexleft ~= 0 and waifuhud.files[ indexleft ] then
        waifuhud.left:SetHTML( htmlcode:gsub( "#GIFMIRROR#", "-1" ):gsub( "#GIFPATH#", waifuhud.folder .. waifuhud.files[ indexleft ] ) )
    else
        waifuhud.left:Hide()
    end

    if indexright ~= 0 and waifuhud.files[ indexright ] then
        waifuhud.right:SetHTML( htmlcode:gsub( "#GIFMIRROR#", "1" ):gsub( "#GIFPATH#", waifuhud.folder .. waifuhud.files[ indexright ] ) )
    else
        waifuhud.right:Hide()
    end

    -- Если чел меняет разрешение
    hook.Add( "OnScreenSizeChanged", "waifuhud:resolution", function() waifuhud.changed( "waifuhud_size" ) end )

    -- Всё, что связано с HUD'ом
    local lp, hp, ar
    local wep, wep1, wep1a, wep1b, wep2, wep2a, wep2b
    local tw, th, lo, ro, clrl, clrr

    hook.Add( "HUDPaint", "waifuhud:hud", function()
        if not waifuhud.cv_customhud:GetBool() then return end

        lp = LocalPlayer()
        if not IsValid( lp ) then return end

        lo = math_max( 50, size )
        clrl = waifuhud.color_left

        -- Здоровье
        hp = tostring( lp:Health() )

        tw, th = draw_SimpleText( "HP", "waifuhudMediumGlow", lo, sh - 70, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
        draw_SimpleText( "HP", "waifuhudMedium", lo, sh - 70, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
        draw_SimpleText( hp, "waifuhudBigGlow", lo + tw + 5, sh - 65, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
        draw_SimpleText( hp, "waifuhudBig", lo + tw + 5, sh - 65, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

        -- Броня
        ar = lp:Armor()
        
        if ar > 0 then
            ar = tostring( ar )

            tw, th = draw_SimpleText( "AR", "waifuhudMediumGlow", lo, sh - 20, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
            draw_SimpleText( "AR", "waifuhudMedium", lo, sh - 20, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
            draw_SimpleText( ar, "waifuhudBigGlow", lo + tw + 5, sh - 15, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
            draw_SimpleText( ar, "waifuhudBig", lo + tw + 5, sh - 15, clrl, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
        end

        -- Патроны
        wep = lp:GetActiveWeapon()

        if IsValid( wep ) then
            ro = math_min( sw - 50, sw - size )
            clrr = waifuhud.color_right
            
            wep1a = wep:GetMaxClip1() or -1

            if wep1a > 0 then
                wep1a = tostring( wep1a )
                wep1b = tostring( wep:Clip1() or -1 )

                tw, th = draw_SimpleText( "/" .. wep1a, "waifuhudMediumGlow", ro, sh - 70, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
                draw_SimpleText( "/" .. wep1a, "waifuhudMedium", ro, sh - 70, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

                draw_SimpleText( wep1b, "waifuhudBigGlow", ro - tw - 5, sh - 65, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
                draw_SimpleText( wep1b, "waifuhudBig", ro - tw - 5, sh - 65, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
            end
            
            wep2a = lp:GetAmmoCount( wep:GetPrimaryAmmoType() ) or -1

            if wep2a > 0 then
                wep2a = tostring( wep2a )
                wep2b = tostring( AmmoTypes[ wep:GetPrimaryAmmoType() ] or "miku" )

                draw_SimpleText( wep2a, "waifuhudMediumGlow", ro, sh - 35, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
                draw_SimpleText( wep2a, "waifuhudMedium", ro, sh - 35, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

                draw_SimpleText( wep2b, "waifuhudSmallGlow", ro, sh - 23, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
                draw_SimpleText( wep2b, "waifuhudSmall", ro, sh - 23, clrr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
            end
        end
    end )

    local tohide = {
        CHudHealth = true,
        CHudBattery = true,
        CHudAmmo = true,
        CHudSecondaryAmmo = true,
    }

    hook.Add( "HUDShouldDraw", "waifuhud:hide", function( name )
        if not waifuhud.cv_customhud:GetBool() then return end

        if tohide[ name ] then
            return false
        end
    end )
end

hook.Add( "PopulateToolMenu", "waifuhud:menu", function()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "waifuhud_settings", "WaifuHud", "", "", function( panel )
		panel:Clear()

        panel:CheckBox( "Enabled", "waifuhud_enabled" )
        panel:Button( "Restart", "waifuhud_restart" )

		panel:NumSlider( "Left", "waifuhud_left", 0, #waifuhud.files, 0 )
        waifuhud.dtextentry_left = panel:TextEntry( "Left" )
        waifuhud.dtextentry_left:SetText( waifuhud.files[ waifuhud.cv_left:GetInt() ] or "hidden" )
        waifuhud.dtextentry_left:SetEnabled( false )

		panel:NumSlider( "Right", "waifuhud_right", 0, #waifuhud.files, 0 )
        waifuhud.dtextentry_right = panel:TextEntry( "Right" )
        waifuhud.dtextentry_right:SetText( waifuhud.files[ waifuhud.cv_right:GetInt() ] or "hidden" )
        waifuhud.dtextentry_right:SetEnabled( false )

		panel:NumSlider( "Size", "waifuhud_size", 0, 512, 0 )
        panel:CheckBox( "Custom Hud", "waifuhud_customhud" )
	end )
end)

cvars.AddChangeCallback( "waifuhud_enabled", waifuhud.switch, "waifuhud_enabled_cb" )
cvars.AddChangeCallback( "waifuhud_left", waifuhud.changed, "waifuhud_left_cb" )
cvars.AddChangeCallback( "waifuhud_right", waifuhud.changed, "waifuhud_right_cb" )
cvars.AddChangeCallback( "waifuhud_size", waifuhud.changed, "waifuhud_size_cb" )

hook.Add( "Initialize", "waifuhud:initialize", function() timer.Simple( 1, waifuhud.initialize ) end )
concommand.Add( "waifuhud_restart", waifuhud.initialize )
