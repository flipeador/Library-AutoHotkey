#Include ..\MCode.ahk





; #######################################################################################################################
; CONSTANTS                                                                                                             #
; #######################################################################################################################
global PI  := ACos(-1)    ; π      = 3.14159265358979323846264.    [http://www.geom.uiuc.edu/~huberty/math5337/groupe/digits.html]
global Tau := 2*ACos(-1)  ; τ (2π) = 6.28318530717958647692528.





; #######################################################################################################################
; FUNCTIONS                                                                                                             #
; #######################################################################################################################
/*
    Converts a number range to another range, maintaining ratio.
    Parameters:
        Value:
            The number to be converted.
        OldMin / OldMax:
            The current value range.
        NewMin / NewMax:
            The new range.
    Return value:
        Returns a floating-point number in the specified range.
*/
Remap(Value, OldMin, OldMax, NewMin, NewMax)
{
    return DllCall(IMath.pRemap, "Double", Value, "Double", OldMin, "Double", OldMax, "Double", NewMin, "Double", NewMax, "Double")
} ; https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio





/*
    Calculates the arctangent of x/y.
*/
ATan2(X, Y)
{
    return DllCall("msvcrt.dll\atan2", "Double", Y, "Double", X, "Cdecl Double")
} ; https://autohotkey.com/board/topic/88476-vincenty-formula-for-latitude-and-longitude-calculations/





/*
    Find the greatest common divisor (GCD) of two numbers using the euclidean algorithm.
*/
GCD(X, Y)
{
    return DllCall(IMath.pGCD, "UPtr", X, "UPtr", Y, "UPtr")
} ; https://autohotkey.com/boards/viewtopic.php?f=6&t=3514&start=20#p23995





/*
    Calculates the average of the specified values.
*/
Average(Numbers*)
{
    local Number, Total := 0
    for Number In Numbers
        Total += Number + 0.0
    return Total / Numbers.Length()
}





PopCount(X)
{
    return DllCall(IMath.pPopCount, "UInt64", X, "UInt")
} ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3514&start=40#p24647





IsPrime(Number)
{
    loop Floor(Sqrt(Number))
        if ((A_Index > 1) && (!Mod(Number,A_Index)))
            return FALSE
    return TRUE
}





Percent(Number, Percent)
{
    return (Number / 100.0) * Percent
}





/*
    Quantifies the change from one number to another and express the change as an increase or decrease.
    Percentage change is usually calculated when there is an "Old" and "New" number or an "initial" and "final" value.
    A positive change is expressed as an increase amount of the percentage value while a negative change is expressed as a decrease amount of the absolute value of the percentage value.
*/
PercentChange(Number1, Number2)
{
    return ((Number2 - Number1) / Abs(Number1)) * 100.0
} ; http://www.calculatorsoup.com/calculators/algebra/percent-change-calculator.php





/*
    Finds the percent difference between two numbers.
    Percentage difference is usually calculated when you want to know the difference in percentage between two numbers.
*/
PercentDiff(Number1, Number2)
{
    if ((Number1 < 0) && (Number2 > -1))
        Number1 := Abs(Number1), Number2 += Number1
    If ((Number1 > -1) && (Number2 < 0))
        Number2 := Abs(Number2), Number1 += Number2
    return (Abs(Number1 - Number2) * 100.0 / ((Number1 + Number2) / 2.0))
} ; http://www.calculatorsoup.com/calculators/algebra/percent-difference-calculator.php





Factorial(Number)
{
    local Factorial := 1
    loop Number
        Factorial *= A_Index
    return Factorial  ; return (Number > 1 ? Number-- * Factorial(Number) : 1)
} ; http://rosettacode.org/wiki/Factorial#AutoHotkey





Between(Number, Low, High, ExcludeValues*)
{
    Local ExcludeValue
    for ExcludeValue in ExcludeValues
        if (ExcludeValue == Number)
            return FALSE
    return (Number >= Low && Number <= High)
}





/*
    Expands numbers in range form to number series.
    Parameters:
        Range:
            A string with numbers in abbreviated range form.
            For example: "-10--6,-5,-1--4,0,1,2,3-6,10-7" —> "-10,-9,-8,-7,-6,-5,-1,-2,-3,-4,0,1,2,3,4,5,6,10,9,8,7".
        RangeLimit:
            An array with two integers specifying the high/low boundary.
        Unique:
            True/False. True will omit duplicate numbers from output.
        Delimiter:
            A string with the delimiter that separates the ranges of numbers in the string specified in the «Range» parameter.
            An array with [Delimiter,Delimiter2,OmitChars?]. «Delimiter2» specifies the delimiter used in the output.
    Return value:
        Returns a string with the expanded numbers.
*/
ExpandRange(Range, RangeLimit := 0, Unique := FALSE, Delimiter := ",")
{
    local

    Delimiter  := IsObject(Delimiter)  ? Delimiter    : Array(Delimiter,",")
    OmitChars  := Delimiter.Length > 2 ? Delimiter[3] : "`s`t`r`n"
    RangeLimit := IsObject(RangeLimit) ? RangeLimit   : 0
    ExpdRange  := Delimiter[2]

    loop parse, Range, Delimiter[1], OmitChars
    {
        Range := StrSplit(A_LoopField . ".." . A_LoopField, "..", OmitChars, 3)
        Range := Array(Integer(Range[1]), Integer(Range[2]))
        loop ( Abs(Range[1] - Range[2]) + 1 )
        {
            Number    := Range[1]<Range[2] ? Range[1]+A_Index-1 : Range[1]-A_Index+1
            ExpdRange .= Unique && InStr(ExpdRange, Delimiter[2] . Number . Delimiter[2]) ? ""
                       : !RangeLimit||Number>=RangeLimit[1]&&Number<=RangeLimit[2] ? Number . Delimiter[2] : ""
        }
    }

    return Trim(ExpdRange, Delimiter[2])
} ; https://www.autohotkey.com/boards/viewtopic.php?p=290517





; #######################################################################################################################
; MACHINE CODE POINTERS                                                                                                 #
; #######################################################################################################################
class IMath
{
    static pRemap := MCode("8g8QZCQM8g8QdCQUZg8u5p/2xER7ePIPEGwkHPIPEEQkJGYPLuif9sREe3nyDxBUJAQPKN0PKMzyD1/YDyj98g9dzvIPXfjyD1/mDyjD8g9c0WYPLv3yD1zH8g9c4Z/yD1nQ8g9e1PbERHoR8g9Y1/IPEVQkDN1EJAzCKADyD1za8g8RXCQM3UQkDMIoAGgAAAAAjUQkEMdEJBABAAAAUOgAAAAAaAAAAACNRCQQx0QkEAIAAABQ6AAAAADM"
                               , "SIPsSGYPLsoPKXwkIA8o6Q8o+g8o4HoCdHvyDxBEJHBmDy7YegYPhIMAAAAPKNMPKXQkMPIPX9APKPPyD13w8g9dz/IPX+8PKMJmDy7z8g9c4fIPXMbyD1zp8g9Z4PIPXuV6GHUW8g9Y5g8odCQwDyjEDyh8JCBIg8RIww8odCQw8g9c1A8ofCQgDyjiDyjCSIPESMNIjRUAAAAAx0QkWAEAAABIjUwkWOgAAAAAzEiNFQAAAADHRCRYAgAAAEiNTCRY6AAAAADM")

    static pGCD := MCode("i0wkCItEJASFyXQQDx9AADPS9/GLwYvKhdJ19MIIAA=="
                             , "TIvCSIXSdBsPH4QAAAAAADPSSIvBSffwSYvITIvCSIXSde1Ii8HD")

    static pPopCount := MCode("U1aLdCQMM9tXi3wkFIvGC8d0FYvWi8+Dwv+D0f8j8iP5Q4vOC891619ei8NbwggA"
                                  , "M8BIhcl0FGYPH4QAAAAAAEiNUf//wEgjynX1ww==")
}
