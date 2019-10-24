; ===================================================================================================================
; EXAMPLE 4.2 : Apply a Gaussian Blur Effect to a Bitmap.
; ===================================================================================================================
#Warn
#SingleInstance Force

#Include ..\..\Graphics.ahk

Gdiplus.Startup()


CoordMode("ToolTip", "Client")

; Creates a Bitmap image from a file selected by the user.
Bitmap := Gdiplus.Bitmap.FromFile(FileSelect())
if (!Bitmap)
    throw Exception(Format("0x{:08X}`s-`sError creating the Bitmap image.",Gdiplus.LastStatus), -1)

; Creates a Gui window.
Gui := GuiCreate("-DPIScale", "Apply a Gaussian Blur Effect to a Bitmap")
Gui.MarginX := 5, Gui.MarginY := 5
Gui.SetFont("s9", "Segoe UI")

Slider := Gui.AddSlider("w500 h30 TickInterval5 Page10 Line5 Range0-255 AltSubmit")
Slider.OnEvent("Change", (*)=>ToolTip("Radius: " . Slider.Value) . SetTimer(()=>!GetKeyState("LButton")&&ToolTip(),-100))

CB := Gui.AddCheckbox("x510 y5 w143 h30", "ExpandEdge")
CB.OnEvent("Click", (*)=>CB.SetFont(CB.Value?"Bold":"Norm"))

Btn := Gui.AddButton("x658 y5 w100 h30 Default", "Apply")
Btn.OnEvent("Click", "Update")

Pic := Gui.AddPic("x5 y40 w750 h650 Border", "HBITMAP:" . Bitmap.CreateHBitmap())

Gui.OnEvent("Escape", "ExitApp")
Gui.OnEvent("Close", "ExitApp")
Gui.Show()
return





; ===================================================================================================================
; FUNCTIONS
; ===================================================================================================================
Update(*)
{
    global Gui, Bitmap, Slider, CB, Pic

    Gui.Opt("+Disabled")

    ; Creates a Blur object.
    local Blur := Gdiplus.Effect.Blur()

    ; Creates a BlurParams object.
    ; A BlurParams object contains members that specify the nature of a Gaussian blur.
    local BlurParams := Gdiplus.BlurParams()

    ; Sets the members of the BlurParams structure.
    BlurParams.Radius     := Slider.Value  ; The blur radius (0-255) in pixels. As the radius increases, the resulting bitmap becomes more blurry.
    BlurParams.ExpandEdge := CB.Value      ; Boolean value that specifies whether the bitmap expands by an amount equal to the blur radius.

    ; Sets the parameters for this Blur object.
    Blur.SetParameters(BlurParams)  ; Gdiplus::Effect::SetParameters method.

    ; Creates a new Bitmap image and applies the blur effect.
    ; The second parameter can be a IRect object that specifies the area in which to apply the effect.
    ; - A value of zero (the default value) applies the effect to the entire image.
    ; The Bitmap::ApplyEffect method applies the effect to this image.
    ; The Graphics::DrawImageFX method allows to apply the effect before drawing the image on the graphics object.
    local BlurredBitmap := Bitmap.ApplyEffect2(Blur)

    ; Sets the Bitmap image to the Pic control.
    ; The Bitmap::CreateHBITMAP method creates a GDI bitmap from this Bitmap object.
    ; The old GDI Bitmap image is automatically destroyed by AHK when we set a new one.
    Pic.Value := "HBITMAP:" . BlurredBitmap.CreateHBITMAP()

    Gui.Opt("-Disabled")
    Gui.Show()
}
