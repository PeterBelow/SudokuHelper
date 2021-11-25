{!
<summary>
 This unit collects some common type declarations.</summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2006-10-06<p>
 Version 1.1 created 2008-03-17 for Delphi 2009<p>
 Version 1.2 created 2009-03-14, added EPreconditionViolation.<p>
 Version 1.3 created 2014-03-10, added EPreconditionViolation.Create
  overload to accept a format string and parameters.<p>
 Version 1.4 created 2016-05-19, changed unit name to use the
 new qualified name syntax<p>
 Version 1.5 created 2019-08-04, refactored the exception class
   hierarchy to make it easier to derive other classes from the common
   base class.
 Last modified       2019-08-04<p>
</history>
<copyright>Copyright 2009, 2019 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
}
unit PB.CommonTypesU;

interface
{$INCLUDE PBDEFINES.INC}
uses System.Sysutils;

type
  {! <summary> a dynamic array of bytes  </summary> }
  TDynByteArray = array of Byte;
  {! <summary> a dynamic array of integers  </summary> }
  TIntegerArray = array of Integer;
  {! <summary> a dynamic array of doubles  </summary> }
  TDoubleArray  = array of Double;
  {! <summary> a dynamic array of singles  </summary> }
  TSingleArray  = array of Single;
  {! <summary> a dynamic array of strings  </summary> }
  TStringArray  = array of String;
  {! <summary> a dynamic array of object references  </summary> }
  TObjectArray  = array of TObject;
  {! <summary> a dynamic array of interface references  </summary> }
  TInterfaceArray = array of IInterface;
  {$IFNDEF UNICODE}
  {! <summary> define an alias for pre-Unicode Delphi versions  </summary> }
  UnicodeString = Widestring;
  {! <summary> define an alias for pre-Unicode Delphi versions  </summary> }
  UnicodeChar   = WideChar;
  {! <summary> define an alias for pre-Unicode Delphi versions  </summary> }
  TBytes        = TDynByteArray;
  {$ELSE}
  {! <summary> define an alias  for Unicode Delphi versions  </summary> }
  UnicodeChar   = Char;
  {$ENDIF}

  {!
  <remarks>
   TDynArray offers a number of static methods to convert an open
   array to a dynamic array of the appropriate type. It can also copy an
   arbitrary block of memory to a TDynByteArray.   </remarks>
  }
  TDynArray = class
  public
    {!
    <summary>
     Creates a dynamic array of bytes from the passed open array. </summary>
    }
    class function ByteArray(const A: array of Byte):TDynByteArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Creates a dynamic array of integer from the passed open array. </summary>
    }
    class function IntegerArray(const A: array of Integer):TIntegerArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Creates a dynamic array of double from the passed open array. </summary>
    }
    class function DoubleArray(const A: array of Double):TDoubleArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Creates a dynamic array of single from the passed open array. </summary>
    }
    class function SingleArray(const A: array of Single):TSingleArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Creates a dynamic array of string from the passed open array. </summary>
    }
    class function StringArray(const A: array of String):TStringArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Creates a dynamic array of TObject from the passed open array. </summary>
    }
    class function ObjectArray(const A: array of TObject):TObjectArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Creates a dynamic array of IInterface from the passed open array. </summary>
    }
    class function InterfaceArray(const A: array of IInterface):TInterfaceArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Matches the starting area of two byte arrays. </summary>
    <returns>
     True if aArray starts with the bytes in aSubArray, false if not or
     if aSubArray is larger than aArray.</returns>
    <param name="aSubArray">contains the bytes to match.</param>
    <param name="aArray">contains the bytes to match against. This array
     has to be at least as large as aSubArray for a valid match.</param>
    }
    class function StartsWith(const aSubArray, aArray: TDynByteArray):
        Boolean;   {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    {!
    <summary>
     Copies an arbitrary block of memory to a byte array. </summary>
    <returns>
     the created array.</returns>
    <param name="Data">contains the bytes to copy.</param>
    <param name="NumBytes">is the number of bytes to copy from Data.</param>
    <exception cref="EAccessViolation">
     is raised if the block of NumBytes bytes starting at the address
     of Data is not in a valid memory range for the current process. </exception>
    }
    class function ToByteArray(const Data; NumBytes: Cardinal): TDynByteArray;
    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
  end;

  {!
  <summary>
   Base exception class used to derive specific exception classes
   for pre- and postcondition errors from. </summary>
  <remarks>
   The class basically provides several constructors to compose
   the error message from a exception specific format mask and
   parameters, usually the name of the faulting routine and a
   detailed message for the error encountered. </remarks>
  }
  EPBBaseException = class(Exception)
  protected
    {!
    <summary>
     Returns a format mask with two replacement string parameters to use
     for the error message the constructor will compose.</summary>
    <remarks>
     Descendants must override this method!</remarks>
    }
    function GetFormatMask: string; virtual; abstract;
  public
    {!
    <summary>
     Composes an error message from the format mask returned by
     <see cref="GetFormatMask"/> and the passed parameters.</summary>
    <param name="Procname">
     is the name of the method that raises the exception</param>
    <param name="Msg">
     is the error message</param>
    }
    constructor Create(const Procname, Msg: string); overload;
    {!
    <summary>
     Composes an error message from the passed parameters.</summary>
    <param name="Procname">
     is the name of the method that raises the exception</param>
    <param name="Fmt">
     is a format mask to use to compose the error message</param>
    <param name="Params">
     contains the replacement values for the format mask</param>
    <remarks>
     Fmt and Params are passed directly to the Sysutils.Format function
      </remarks>
    }
    constructor Create(const Procname, Fmt: string; const Params: Array of
        const); overload;
    {!
    <summary>
     Composes an error message from the format mask returned by
     <see cref="GetFormatMask"/> and the passed parameters.</summary>
    <param name="aObj">
     is the object that raises the exception, should not be nil!</param>
    <param name="Procname">
     is the name of the method that raises the exception. It will be
     prefixed by the class name of aObj</param>
    <param name="Msg">
     is the error message</param>
    <remarks>
     The constructor deals with a nil aObj by using a dummy class
     name in the constructed message, which is a bit useless but
     avoids a  nil reference exception</remarks>
    }
    constructor Create(aObj: TObject; const Procname, Msg: string); overload;
  end;

  type
  {!
  <remarks>
   This exception class is used to report a preconditon
   violation in a routine. </remarks>
  }
  EPreconditionViolation = class(EPBBaseException)
  protected
    {!
    <summary>
     Returns a format mask with two replacement string parameters to use
     for the error message the constructor will compose.</summary>
    }
    function GetFormatMask: string; override;

  end;

  {!
  <remarks>
   This exception class is used to report bad parameters
   passed to a routine. </remarks>
  }
  EInvalidParameter = class(EPreconditionViolation)
  protected
    {!
    <summary>
     Returns a format mask with two replacement string parameters to use
     for the error message the constructor will compose.</summary>
    }
    function GetFormatMask: string; override;
  end;
  {!
   <remarks>
    This exception class is raised if nil is passed for a
    parameter that cannot be nil. </remarks>
  }
  EParameterCannotBeNil = class(EInvalidParameter)
  protected
    {!
    <summary>
     Returns a format mask with two replacement string parameters to use
     for the error message the constructor will compose.</summary>
    }
    function GetFormatMask: string; override;
  end;
  {!
  <remarks>
   This exception class is used to report a postconditon
   violation in a routine. </remarks>
  }
  EPostconditionViolated = class(EPreconditionViolation)
  protected
    {!
    <summary>
     Returns a format mask with two replacement string parameters to use
     for the error message the constructor will compose.</summary>
    }
    function GetFormatMask: string; override;
  end;

implementation

//NODOC-BEGIN

resourcestring
  SPreconditionViolated  = 'Routine %s: Precondition violated: %s.';
  SPostconditionViolated = 'Routine %s: Postcondition violated: %s.';
  SBadValueForParameter  = 'Routine %s: Bad value for parameter %s.';
  SParameterCannotBeNil  = 'Routine %s: Parameter %s cannot be nil.';

//NODOC-END

constructor EPBBaseException.Create(const Procname, Msg: string);
begin
  CreateFmt(GetFormatMask, [Procname, Msg]);
end;

constructor EPBBaseException.Create(aObj: TObject; const Procname,
  Msg: string);
begin
  if Assigned(aObj) then
    CreateFmt(GetFormatMask, [aObj.ClassName + '.' + Procname, Msg])
  else
    CreateFmt(GetFormatMask, ['<unknown class>.' + Procname, Msg]);
end;

constructor EPBBaseException.Create(const Procname, Fmt: string;
    const Params: Array of const);
begin
  Create(Procname, Format(Fmt, Params));
end;

function EPreconditionViolation.GetFormatMask: string;
begin
  Result := SPreconditionViolated;
end;

function EInvalidParameter.GetFormatMask: string;
begin
  Result := SBadValueForParameter;
end;

function EParameterCannotBeNil.GetFormatMask: string;
begin
  Result := SParameterCannotBeNil;
end;

function EPostconditionViolated.GetFormatMask: string;
begin
  Result := SPostconditionViolated;
end;



class function TDynArray.ByteArray(const A: array of Byte): TDynByteArray;
begin
  SetLength(Result, Length(A));
  if Length(A) > 0 then
    Move(A[0], Result[0], Length(A)*Sizeof(A[0]));
end;

class function TDynArray.DoubleArray(
  const A: array of Double): TDoubleArray;
begin
  SetLength(Result, Length(A));
  if Length(A) > 0 then
    Move(A[0], Result[0], Length(A)*Sizeof(A[0]));
end;

class function TDynArray.IntegerArray(
  const A: array of Integer): TIntegerArray;
begin
  SetLength(Result, Length(A));
  if Length(A) > 0 then
    Move(A[0], Result[0], Length(A)*Sizeof(A[0]));
end;

class function TDynArray.InterfaceArray(
  const A: array of IInterface): TInterfaceArray;
var
  I: Integer;
begin
  SetLength(Result, Length(A));
  for I := 0 to High(A) do
     Result[I] := A[I];
end;

class function TDynArray.ObjectArray(
  const A: array of TObject): TObjectArray;
begin
  SetLength(Result, Length(A));
  if Length(A) > 0 then
    Move(A[0], Result[0], Length(A)*Sizeof(A[0]));
end;

class function TDynArray.SingleArray(
  const A: array of Single): TSingleArray;
begin
  SetLength(Result, Length(A));
  if Length(A) > 0 then
    Move(A[0], Result[0], Length(A)*Sizeof(A[0]));
end;

class function TDynArray.StartsWith(const aSubArray, aArray: TDynByteArray):
    Boolean;
begin
  Result := (Length(aArray) >= Length(aSubArray))
    and CompareMem(@aSubArray[0], @aArray[0], Length(aSubArray));
end;

class function TDynArray.StringArray(
  const A: array of String): TStringArray;
var
  I: Integer;
begin
  SetLength(Result, Length(A));
  for I := 0 to High(A) do
     Result[I] := A[I];
end;

class function TDynArray.ToByteArray(const Data; NumBytes: Cardinal):
    TDynByteArray;
begin
  SetLength(Result, NumBytes);
  if NumBytes > 0 then
    Move(Data, Result[0], NumBytes);
end;

end.


