{!
<summary>
 This unit declares a number of typesafe wrappers for the Windows
  Interlocked* functions.</summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2007-01-17<p>
 Version 1.1 created 2012-08-07, modified to use SyncObjs.TInterlocked.<p>
 Version 1.2 created 2016-05-19, changed unit name to use the
 new qualified name syntax<p>
 Last modified       2016-05-19<p>
</history>
<copyright>Copyright 2009-2012 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
}
unit PB.InterlockedOpsU;
{$INCLUDE PBDEFINES.INC}
interface

{! <summary>
Places the passed Value into the memory location of Target and returns
the old content of Target.</summary>
<remarks>
Target has to be a variable of Sizeof(TObject) bytes at minimum! The
operation is thread-safe.</remarks> }
function InterlockedExchangeObject(
  var Target; Value: TObject): TObject; stdcall;

{! <summary>
Places the passed Value into the memory location of Target and returns
the old content of Target.</summary>
<remarks>
Target has to be a variable of Sizeof(THandle) bytes at minimum! The
operation is thread-safe.<p>
The function can be used to swap interface references by casting them
to TObject. Just keep in mind that this will not update the interface
reference counts appropriately!</remarks> </remarks> }
function InterlockedExchangeHandle(
  var Target; Value: THandle): THandle; stdcall;

{! <summary>
Compares the current value of Target with Comparand. If they
are equal the old content of Target is replaced with Exchange.</summary>
<returns> the old value of Target.</returns>
<remarks> Target has to be a variable of Sizeof(TObject) bytes at
minimum! The operation is thread-safe.<p>
The function can be used to swap interface references by casting them
to TObject. Just keep in mind that this will not update the interface
reference counts appropriately!<p>
 
CAVEAT! With Delphi 2010 a cast like TObject(InterfaceVar) is no longer
a NOP! Do it as TObject(Pointer(InterfaceVar)) or it will not work as
intended and can even cause an access violation if InterfaceVar happens to
be nil!</remarks> }
function InterlockedCompareExchangeObject(var Target; Exchange,
    Comparand: TObject): TObject; stdcall;

{! <summary>
Compares the current value of Target with Comparand. If they
are equal the old content of Target is replaced with Exchange.</summary>
<returns> the old value of Target.</returns>
<remarks> Target has to be a variable of Sizeof(THandle) bytes at
minimum! The operation is thread-safe.</remarks> }
function InterlockedCompareExchangeHandle(
  var Target; Exchange, Comparand: THandle): THandle; stdcall;

implementation

uses WinAPI.Windows, System.SyncObjs;

{$IFDEF SUPPORTS_TInterlocked}

function InterlockedExchangeObject(
  var Target; Value: TObject): TObject; stdcall;
begin
  Result := TInterlocked.Exchange(TObject(Target), Value);
end;

function InterlockedExchangeHandle(
  var Target; Value: THandle): THandle; stdcall;
begin
  Result := THandle(TInterlocked.Exchange(Pointer(Target), Pointer(Value)))
end;

function InterlockedCompareExchangeObject(var Target; Exchange,
    Comparand: TObject): TObject; stdcall;
begin
  Result := TInterlocked.CompareExchange(TObject(Target), Exchange, Comparand);
end;

function InterlockedCompareExchangeHandle(
  var Target; Exchange, Comparand: THandle): THandle; stdcall;
begin
  Result := THandle(TInterlocked.CompareExchange(Pointer(Target), Pointer(Exchange), Pointer(Comparand)))
end;

{$ELSE}
  function InterlockedExchangeObject;
  {$IFDEF WIN64}
    external kernel32 name 'InterlockedExchangePointer';
  {$ELSE}
    external kernel32 name 'InterlockedExchange';
  {$ENDIF}
  function InterlockedExchangeHandle;
  {$IFDEF WIN64}
    external kernel32 name 'InterlockedExchangePointer';
  {$ELSE}
    external kernel32 name 'InterlockedExchange';
  {$ENDIF}
  function InterlockedCompareExchangeObject;
  {$IFDEF WIN64}
    external kernel32 name 'InterlockedCompareExchangePointer';
  {$ELSE}
    external kernel32 name 'InterlockedCompareExchange';
  {$ENDIF}
  function InterlockedCompareExchangeHandle;
  {$IFDEF WIN64}
    external kernel32 name 'InterlockedCompareExchangePointer';
  {$ELSE}
    external kernel32 name 'InterlockedCompareExchange';
  {$ENDIF}
{$ENDIF}

end.
