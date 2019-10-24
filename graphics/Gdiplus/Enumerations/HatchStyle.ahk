/*
    The HatchStyle enumeration specifies the hatch pattern used by a brush of type HatchBrush.
    The hatch pattern consists of a solid background color and lines drawn over the background.

    HatchStyle Enumeration:
        https://docs.microsoft.com/en-us/windows/win32/api/gdiplusenums/ne-gdiplusenums-hatchstyle
*/
class HatchStyle
{
    static HatchStyleHorizontal             := 0    ; Specifies horizontal lines.
    static HatchStyleVertical               := 1    ; Specifies vertical lines.
    static HatchStyleForwardDiagonal        := 2    ; Specifies diagonal lines that slant to the right from top points to bottom points. The lines are antialiased.
    static HatchStyleBackwardDiagonal       := 3    ; Specifies diagonal lines that slant to the left from top points to bottom points. The lines are antialiased.
    static HatchStyleCross                  := 4    ; Specifies horizontal and vertical lines that cross at 90-degree angles.
    static HatchStyleDiagonalCross          := 5    ; Specifies forward diagonal and backward diagonal lines that cross at 90-degree angles. The lines are antialiased.
    static HatchStyle05Percent              := 6    ; Specifies a 5-percent hatch. The ratio of foreground color to background color is 5:100.
    static HatchStyle10Percent              := 7    ; Specifies a 10-percent hatch. The ratio of foreground color to background color is 10:100.
    static HatchStyle20Percent              := 8    ; Specifies a 20-percent hatch. The ratio of foreground color to background color is 20:100.
    static HatchStyle25Percent              := 9    ; Specifies a 25-percent hatch. The ratio of foreground color to background color is 25:100.
    static HatchStyle30Percent              := 10   ; Specifies a 30-percent hatch. The ratio of foreground color to background color is 30:100.
    static HatchStyle40Percent              := 11   ; Specifies a 40-percent hatch. The ratio of foreground color to background color is 40:100.
    static HatchStyle50Percent              := 12   ; Specifies a 50-percent hatch. The ratio of foreground color to background color is 50:100.
    static HatchStyle60Percent              := 13   ; Specifies a 60-percent hatch. The ratio of foreground color to background color is 60:100.
    static HatchStyle70Percent              := 14   ; Specifies a 70-percent hatch. The ratio of foreground color to background color is 70:100.
    static HatchStyle75Percent              := 15   ; Specifies a 75-percent hatch. The ratio of foreground color to background color is 75:100.
    static HatchStyle80Percent              := 16   ; Specifies an 80-percent hatch. The ratio of foreground color to background color is 80:100.
    static HatchStyle90Percent              := 17   ; Specifies a 90-percent hatch. The ratio of foreground color to background color is 90:100.
    static HatchStyleLightDownwardDiagonal  := 18   ; Specifies diagonal lines that slant to the right from top points to bottom points and are spaced 50 percent closer together than HatchStyleForwardDiagonal but are not antialiased.
    static HatchStyleLightUpwardDiagonal    := 19   ; Specifies diagonal lines that slant to the left from top points to bottom points and are spaced 50 percent closer together than HatchStyleBackwardDiagonal but are not antialiased.
    static HatchStyleDarkDownwardDiagonal   := 20   ; Specifies diagonal lines that slant to the right from top points to bottom points, are spaced 50 percent closer together than HatchStyleForwardDiagonal, and are twice the width of HatchStyleForwardDiagonal but are not antialiased.
    static HatchStyleDarkUpwardDiagonal     := 21   ; Specifies diagonal lines that slant to the left from top points to bottom points, are spaced 50 percent closer together than HatchStyleBackwardDiagonal, and are twice the width of HatchStyleBackwardDiagonal but are not antialiased.
    static HatchStyleWideDownwardDiagonal   := 22   ; Specifies diagonal lines that slant to the right from top points to bottom points, have the same spacing as HatchStyleForwardDiagonal, and are triple the width of HatchStyleForwardDiagonal but are not antialiased.
    static HatchStyleWideUpwardDiagonal     := 23   ; Specifies diagonal lines that slant to the left from top points to bottom points, have the same spacing as HatchStyleBackwardDiagonal, and are triple the width of HatchStyleBackwardDiagonal but are not antialiased.
    static HatchStyleLightVertical          := 24   ; Specifies vertical lines that are spaced 50 percent closer together than HatchStyleVertical.
    static HatchStyleLightHorizontal        := 25   ; Specifies horizontal lines that are spaced 50 percent closer together than HatchStyleHorizontal.
    static HatchStyleNarrowVertical         := 26   ; Specifies vertical lines that are spaced 75 percent closer together than HatchStyleVertical (or 25 percent closer together than HatchStyleLightVertical).
    static HatchStyleNarrowHorizontal       := 27   ; Specifies horizontal lines that are spaced 75 percent closer together than HatchStyleHorizontal ( or 25 percent closer together than HatchStyleLightHorizontal).
    static HatchStyleDarkVertical           := 28   ; Specifies vertical lines that are spaced 50 percent closer together than HatchStyleVerical and are twice the width of HatchStyleVertical.
    static HatchStyleDarkHorizontal         := 29   ; Specifies horizontal lines that are spaced 50 percent closer together than HatchStyleHorizontal and are twice the width of HatchStyleHorizontal.
    static HatchStyleDashedDownwardDiagonal := 30   ; Specifies horizontal lines that are composed of forward diagonals.
    static HatchStyleDashedUpwardDiagonal   := 31   ; Specifies horizontal lines that are composed of backward diagonals.
    static HatchStyleDashedHorizontal       := 32   ; Specifies horizontal dashed lines.
    static HatchStyleDashedVertical         := 33   ; Specifies vertical dashed lines.
    static HatchStyleSmallConfetti          := 34   ; Specifies a hatch that has the appearance of confetti.
    static HatchStyleLargeConfetti          := 35   ; Specifies a hatch that has the appearance of confetti composed of larger pieces than HatchStyleSmallConfetti.
    static HatchStyleZigZag                 := 36   ; Specifies horizontal lines of zigzags.
    static HatchStyleWave                   := 37   ; Specifies horizontal lines of tildes.
    static HatchStyleDiagonalBrick          := 38   ; Specifies a hatch that has the appearance of a wall of bricks laid in a backward diagonal direction.
    static HatchStyleHorizontalBrick        := 39   ; Specifies a hatch that has the appearance of a wall of bricks laid horizontally.
    static HatchStyleWeave                  := 40   ; Specifies a hatch that has the appearance of a woven material.
    static HatchStylePlaid                  := 41   ; Specifies a hatch that has the appearance of a plaid material.
    static HatchStyleDivot                  := 42   ; Specifies a hatch that has the appearance of divots.
    static HatchStyleDottedGrid             := 43   ; Specifies horizontal and vertical dotted lines that cross at 90-degree angles.
    static HatchStyleDottedDiamond          := 44   ; Specifies forward diagonal and backward diagonal dotted lines that cross at 90-degree angles.
    static HatchStyleShingle                := 45   ; Specifies a hatch that has the appearance of shingles laid in a forward diagonal direction.
    static HatchStyleTrellis                := 46   ; Specifies a hatch that has the appearance of a trellis.
    static HatchStyleSphere                 := 47   ; Specifies a hatch that has the appearance of a checkerboard of spheres.
    static HatchStyleSmallGrid              := 48   ; Specifies horizontal and vertical lines that cross at 90-degree angles and are spaced 50 percent closer together than HatchStyleCross.
    static HatchStyleSmallCheckerBoard      := 49   ; Specifies a hatch that has the appearance of a checkerboard.
    static HatchStyleLargeCheckerBoard      := 50   ; Specifies a hatch that has the appearance of a checkerboard with squares that are twice the size of HatchStyleSmallCheckerBoard.
    static HatchStyleOutlinedDiamond        := 51   ; Specifies forward diagonal and backward diagonal lines that cross at 90-degree angles but are not antialiased.
    static HatchStyleSolidDiamond           := 52   ; Specifies a hatch that has the appearance of a checkerboard placed diagonally.
    static HatchStyleTotal                  := 53   ; Specifies no hatch thereby allowing the brush to be transparent.
    static HatchStyleLargeGrid              := 4    ; Specifies HatchStyleCross.
    static HatchStyleMin                    := 0    ; Specifies HatchStyleHorizonal.
    static HatchStyleMax                    := 52   ; Specifies HatchStyleSolidDiamond.
}
