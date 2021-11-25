{!
<summary>
 This unit collects strings that may be displayed to the user.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-02<p>
 Last modified       2021-11-19<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
<remarks>
 Strings are mostly added by the MMX string to resourcestring or string
 to const wizards.
</remarks>
}
unit SH_StringsU;

interface

resourcestring
  SBlockNotFoundMask = 'Block not found for the Sudoku cell (Col: %d, Row: %d)';
  SSaveFileMessageMask = 'The Sudoku was saved to "%s"';
  SHelpPrompt = 'Press F1 for a brief help overview';
  STheFileDoesNotExist = 'The file "%s" does not exist!';
  SNewMarkMask = 'Mark %d';
  SNewStackMarkPrompt = 'Enter a name for the mark';
  SNewStackMarkCaption = 'New stack mark';
  SRightMask = 'Right: %d';
  SLeftMask = 'Left: %d';
  SMainformCaptionMask = 'Sudoku Helper - %s';

  SAMarkDoesNotExist = 'A mark named "%s" does not exist!';
  STheUndoStackIsEmpty = 'The Undo stack is empty!';
  SAMarkAlreadyExists = 'A mark named "%s" already exists!';
  SNoHelperFound = 'No helper with the display name "%s" has been registered';
  SDisplayHasNotBeenInitializedYet = 'Display has not been initialized yet!';
  SSelectSudokuCaption = 'Known Sudokus';
  SSelectMarkCaption = 'Defined undo stack marks';


implementation

end.













