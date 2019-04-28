# AHkInstance::AHkInstance

Creates an new **AHkInstance object** instance.




### Syntax

```
AHkInstance __New(
  IN String Name
)
```




### Parameters

###### Name

You must specify a unique name for this object of no more than 32 characters.

The specified string must not contain any type of space; Otherwise an exception is thrown.

If there is already an object registered with this name, an exception is throw.




### Return value

Returns the [AHkInstance](AHkInstance.md) class object.




### Remarks

When you no longer use the object, you must call the [Close](AHkInstance-Close.md) method.
