{!
<summary>
 This unit implements classes that can save a Sudoku's state to file
 and load it back from file.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-11-09<p>
 Last modified       2021-11-09<p>
</history>
<remarks>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
</remarks>
}
unit SudokuFilerU;

interface

uses
  SudokuInterfacesU, System.Classes;

type
  {!
   This class just serves as a container for static methods, it is not
   meant to be instanciated. }
  TSudokuFiler = class abstract(TObject)
  public
    class function LoadFromFile(const aFilename: string): ISudokuHelper; static;
    class function LoadFromStream(aStream: TStream): ISudokuHelper; static;
    class procedure SaveToFile(const aSudoku: ISudokuHelper; const aFilename:
        string); static;
    class procedure SaveToStream(const aSudoku: ISudokuHelper; aStream: TStream);
        static;
  end;


implementation

uses
  System.SysUtils,
  System.IOUtils,
  PB.CommonTypesU,
  BaseSudokuHelperU,
  SH_StringsU;

{!
<summary>
 Load a Sudoku from a file. </summary>
<returns>
 The interface for the created helper holding the Sudoku.</returns>
<param name="aFilename">is the full pathname of the file to load.</param>
<exception cref="EPreconditionViolation">
 is raised if the file does not exist.</exception>
<remarks>
 The method expects a file created by the SaveToFile method. Trying
 to load any other file will result in streaming errors.</remarks>
}
class function TSudokuFiler.LoadFromFile(const aFilename: string):
    ISudokuHelper;
const
  CProcname = 'TSudokuFiler.LoadFromFile';
var
  LStream: TFilestream;
begin
  if not TFile.Exists(aFilename) then
    raise EPreconditionViolation.Create(CProcname, STheFileDoesNotExist, [aFilename]);

  LStream := TFilestream.Create(aFilename, fmOpenRead, fmShareDenyWrite);
  try
    Result := LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

{!
<summary>
 Load a Sudoku from a stream. </summary>
<returns>
 The interface for the created helper holding the Sudoku.</returns>
<exception cref="EParameterCannotBeNil">
 is raised if aStream is nil.</exception>
<remarks>
 The method expects a stream written by the SaveToStream method. Trying
 to load any other stream will result in streaming errors.
 Reading starts at the current stream position!</remarks>
}
class function TSudokuFiler.LoadFromStream(aStream: TStream): ISudokuHelper;
const
  CBufSize = 4096 * 4;
  CProcname = 'TSudokuFiler.LoadFromStream';
var
  LName: string;
  LReader: TReader;
begin
  if not Assigned(aStream) then
    raise EParameterCannotBeNil.Create(CProcname,'aStream');
  Result := nil;
  LReader := TReader.Create(astream, CBufSize);
  try
    LName := LReader.ReadString;
    Result := HelperRegistry.CreateInstance(LName);
    Result.Data.Load(LReader);
  finally
    LReader.Free;
  end;
end;

{!
<summary>
 Save a Sudoku to a file. </summary>
<param name="aSudoku">is the interface of the Sudoku to save.</param>
<param name="aFilename">is the full pathname of the file to write.</param>
<exception cref="EParameterCannotBeNil">
 is raised if aSudoku is nil.</exception>
<remarks>
 The method will overwrite an existing file with the passed name. If
 the target folder named in the path does not exist it will be created.</remarks>
}
class procedure TSudokuFiler.SaveToFile(const aSudoku: ISudokuHelper; const
    aFilename: string);
const
  CProcname = 'TSudokuFiler.SaveToFile';
var
  LPath: string;
  LStream: TFilestream;
begin
  if not Assigned(aSudoku) then
    raise EParameterCannotBeNil.Create(CProcname,'aSudoku');

  LPath := TPath.GetDirectoryName(aFilename);
  if TPath.IsDriveRooted(LPath) or TPath.IsUNCRooted(LPath) then
    if not TDirectory.Exists(LPath) then
      TDirectory.CreateDirectory(LPath);

  LStream := TFilestream.Create(aFilename, fmCreate, fmShareExclusive);
  try
    SaveToStream(aSudoku, LStream);
  finally
    LStream.Free;
  end;
end;

{!
<summary>
 Save a Sudoku to a stream. </summary>
<param name="aSudoku">is the interface of the Sudoku to save.</param>
<param name="aStream">is the stream to write to.</param>
<exception cref="EParameterCannotBeNil">
 is raised if aSudoku or aStream are nil.</exception>
<remarks>
 Writing starts at the current stream position.</remarks>
}
class procedure TSudokuFiler.SaveToStream(const aSudoku: ISudokuHelper;
    aStream: TStream);
const
  CBufSize = 4096 * 4;
  CProcname = 'TSudokuFiler.SaveToStream';
var
  LWriter: TWriter;
begin
  if not Assigned(aSudoku) then
    raise EParameterCannotBeNil.Create(CProcname,'aSudoku');
  if not Assigned(aStream) then
    raise EParameterCannotBeNil.Create(CProcname,'aStream');

  LWriter := TWriter.Create(aStream, CBufSize);
  try
    LWriter.WriteString(aSudoku.Displayname);
    aSudoku.Data.Store(LWriter);
    LWriter.FlushBuffer;
  finally
    LWriter.Free;
  end;
end;

end.
