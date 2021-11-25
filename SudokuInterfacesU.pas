{!
<summary>
 This unit defines a number of interface types a Sudoku helper needs to
 implement.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-09-30<p>
 Last modified       2021-11-09<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
<remarks>
A Sudoku helper is specific for a certain type of Sudoku, but to integrate
with the app's UI all helpers have to provide a common set of functionaliy

* Display the Sudoku in a draw grid
* Take user input from keyboard and a set of speed buttons to enter cell
  values and candidates for values a cell can hold
* Provide an undo stack for user actions

This common functionality is defined by a set of interfaces all helpers
have to provide.
</remarks>
}
unit SudokuInterfacesU;

interface

uses
  Grids, System.Classes, PB.CommonTypesU, Vcl.Controls;



{
 Sudokus are square but they differ in the number of allowed values, the
 number of cells in a row (and column), and the size of a block. This makes
 it difficult to come up with a data structure that can both be copied
 en bloc (necessary for an efficient undo stack design) and can be used
 for different types of Sudokus and is type-safe as well.

 I decided to go with a fixed-size cell data approach, supporting at
 max a 16x16 Sudoku, which is about the largest practical. This wastes
 some memory space for smaller Sudokus, but I deemed that to be acceptable.
}
type
{$SCOPEDENUMS ON}
  {! Allowed values of a Sudoku cell }
  TSudokuValue = 0..16;   // 0 = empty cell
  {! Used to represent the still possible values (candidates) of a cell }
  TSudokuValues = set of TSudokuValue;
  {! Indices for a cell in a row or column of the Sudoku are 1-based }
  TSudokuCellIndex = 1..High(TSudokuValue);

  TBlockPosition  = (Left, Top, Right, Bottom, Inside);
  {! Defines the location of a cell in a block, used to determine how
     to draw the cell borders in the UI }
  TCellInBlockLocation = set of TBlockPosition;

  TRightClickAction = (SetCandidate, UnsetCandidate, ToggleGosu);

  TRedrawCellEvent = procedure (aCol, aRow: TSudokuCellIndex) of object;

  {!
  <summary>
   The main form has to implement this interface to allow the input
   handler to retrieve information from it. </summary>
  }
  ISudokuHostform = interface(IInterface)
  ['{43B9FC00-583F-4496-A340-4DA07A6FB656}']
    function GetButtonsContainer: TWincontrol;
    function GetCurrentCandidate: TSudokuValue;
    function GetCurrentValue: TSudokuValue;
    function GetModifierkeys: TShiftstate;
    function GetRightClickAction: TRightClickAction;
    {!
    <value>
     Container for the value speedbuttons
    </value>}
    property ButtonsContainer: TWincontrol read GetButtonsContainer;
    {!
    <value>
     Selected candidate value in the buttons group
    </value>}
    property CurrentCandidate: TSudokuValue read GetCurrentCandidate;
    {!
    <value>
     Selected value in the buttons group
    </value>}
    property CurrentValue: TSudokuValue read GetCurrentValue;
    {!
    <value>
     State of Ctrl and Alt.
    </value>}
    property Modifierkeys: TShiftstate read GetModifierkeys;
    {!
    <value>
     Action to perform on a right mouse click on the Sudoku grid.
    </value>}
    property RightClickAction: TRightClickAction read GetRightClickAction;
  end;

  {!
  <summary>
   The UI uses this interface implemented by the helper to initialize
   the draw grid used to display the Sudoku. </summary>
  }
  ISudokuDisplay = interface(IInterface)
  ['{FFCB1047-5CB6-43FF-BF0B-0C897F8884A9}']
    {!
    <summary>
     Set up the draw grid as appropriate for the supported Sudoku type. </summary>
    <param name="aGrid">is the grid to initialize, cannot be nil</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aGrid is nil. </exception>
    <remarks>
     This method must be called once to connect the helper to the UI!</remarks>
    }
    procedure InitializeGrid(aGrid: TDrawGrid);
    {!
    <summary>
     Check if the display has been initialized </summary>
    }
    function IsInitialized: boolean;
    {!
    <summary>
     Force a complete redraw of the grid. </summary>
    }
    procedure Refresh;
  end;

  {!
  <summary>
   This interface gives access to a single cell of the Sudoku. Its
   implementor has to make sure the UI is updated as needed when the
   content or state of the cell is changed. </summary>
  }
  ISudokuCell = interface(IInterface)
  ['{297A2DBD-BD80-4FEE-9C8B-DB7E3CBB9BA2}']
    {!
    <summary>
     Add a candidate value to the cell. Only does anything if the cell
     is empty. The action can be undone. </summary>
    <param name="aValue">Value to add to the candidate list. The
     caller has to ensure this is a valid value for the Sudoku!</param>
    <remarks>
     A value of 0 is ignored, this is never a valid candidate.</remarks>
    }
    procedure AddCandidate(aValue: TSudokuValue);
    {!
    <summary>
     Set the cell to empty and valid, clear the candidate list. </summary>
    }
    procedure Clear;
    {! Getter for the BlockLocation property }
    function GetBlockLocation: TCellInBlockLocation;
    {! Getter for the Candidates property }
    function GetCandidates: TSudokuValues;
    {! Getter for the Col property }
    function GetCol: TSudokuCellIndex;
    {! Getter for the EvenOnly property }
    function GetEvenOnly: Boolean;
    {! Getter for the Row property }
    function GetRow: TSudokuCellIndex;
    {! Getter for the Value property }
    function GetValue: TSudokuValue;
    {!
    <summary>
     Check whether the cell is empty </summary>
    }
    function IsEmpty: Boolean;
    {!
    <summary>
     Check whether the cell is valid. </summary>
    }
    function IsValid: Boolean;
    {!
    <summary>
     Remove a candidate value from the cell. Only does anything if the cell
     is empty and aValue is in the candidate list. The action can be undone.
     </summary>
    <param name="aValue">Value to remove from the candidate list.</param>
    }
    procedure RemoveCandidate(aValue: TSudokuValue);
    {! Setter for the Value property, also updates the Valid property.
       This action can be undone. }
    procedure SetValue(const Value: TSudokuValue);
    {! Toggle the EvenOnly property, use only for Sudoku Gosu! Also
     updates the Valid state id the cell is not empty. This action can be
     undone. }
    procedure ToggleEvenOnly;
    {!
    <value>
     Describes the position of the cell in the surrounding block.
    </value>}
    property BlockLocation: TCellInBlockLocation read GetBlockLocation;
    {!
    <value>
     Set of candidates set for the cell.
    </value>}
    property Candidates: TSudokuValues read GetCandidates;
    {!
    <value>
     The cell's column index.
    </value>}
    property Col: TSudokuCellIndex read GetCol;
    {!
    <value>
     True if the cell can only hold even values, false otherwise.
    </value>}
    property EvenOnly: Boolean read GetEvenOnly;
    {!
    <value>
     The cell's row index.
    </value>}
    property Row: TSudokuCellIndex read GetRow;
    {!
    <value>
     The cell's value. 0 indicates an empty cell.
    </value>}
    property Value: TSudokuValue read GetValue write SetValue;
  end;

  {! The Sudoku's data storage implements this interface to allow a client
    (the display handler) to attach handlers to events that fire when
    data changes or the display for a cell needs to be redrawn.  }
  ISudokuDataEvents = interface(IInterface)
  ['{360B7556-CD9B-48B6-B400-858573CBD854}']
    function GetOnDataChanged: TNotifyEvent;
    function GetOnRedrawCell: TRedrawCellEvent;
    procedure SetOnDataChanged(const Value: TNotifyEvent);
    procedure SetOnRedrawCell(const Value: TRedrawCellEvent);
    {!
    <value>
     This event fires when the Sudoku changes in a manner that warrants
     a complete redraw of the display, e.g. after an Undo action.
    </value>}
    property OnDataChanged: TNotifyEvent read GetOnDataChanged write
        SetOnDataChanged;
    {!
    <value>
     This event fires when a cell needs to be redrawn since its value,
     valid state, or candidate list has changed.
    </value>}
    property OnRedrawCell: TRedrawCellEvent read GetOnRedrawCell write
        SetOnRedrawCell;
  end;

  {! This interface is implemented by the Sudoku helper to give clients
    access to the basic parameters of the Sudoku.  }
  ISudokuProperties = interface(IInterface)
  ['{4919B7AC-CA22-4AAC-8F13-D008734E8368}']
    function GetBlockHeight: TSudokuValue;
    function GetBlockWidth: TSudokuValue;
    function GetMaxValue: TSudokuValue;
    {!
    <value>
     Number of rows in a block of cells
    </value>}
    property BlockHeight: TSudokuValue read GetBlockHeight;
    {!
    <value>
     Number of columns in a block of cells
    </value>}
    property BlockWidth: TSudokuValue read GetBlockWidth;
    {!
    <value>
     Highest valid value for a cell.
    </value>}
    property MaxValue: TSudokuValue read GetMaxValue;
  end;


  {!
  <summary>
   Interface for the object handling the mouse and keyboard input
   for a Sudoku </summary>
  }
  ISudokuInputHandler = interface(IInterface)
  ['{824E901F-260F-4DDA-9B97-54DAF42BAC3B}']
    {!
    <summary>
     Handle a mouse click (or tap) on a cell of the Sudoku grid </summary>
    <param name="aCol">is the grid column of the clicked cell</param>
    <param name="aRow">is the grid row of the clicked cell</param>
    <param name="aRightClick">false indicates a click with the left
     mouse button, true a click with the right one.</param>
    }
    procedure HandleCellClick(aCol, aRow: Integer; aRightClick: Boolean = false);
    {!
    <summary>
     Handle keyboard input from the Sudoku grid </summary>
    <param name="aCol">is the grid column of the active cell</param>
    <param name="aRow">is the grid row of the active cell</param>
    <param name="aChar">is the character entered</param>
    <remarks>
     A character not valid for our purpose is ignored. The method will

     * set the cell value if aChar represents one of the valid Sudoku
       values (1..MaxValue) and neither Alt nor Ctrl are held down. If
       aChar is '1' and MaxValue is 10 or higher a delay mechanism may
       be used to allow a second call to complete a two character sequence.
       (Not implemented currently!)
       Alternatively letters A to G can be used to input the values 10
       to 16.
     * clear the cell if aChar is '0'.
     * set a candidate if the cell is empty and Alt is down.
     * remove a candidate if the cell is empty and Ctrl is down.
     * toggle the even only state of the cell if aChar is a space.

    </remarks>
    }
    procedure HandleCharacter(aCol, aRow: Integer; aChar: Char);
    {!
    <summary>
     Connect the input handler to the main form
    <param name="aHost">represents the main form, required</param>
    <exception cref="EParameterCannotBeNil">
     is raised if  aHost is nil </exception>
    <remarks>
     The input handler creates a set of speedbutttons on a container
     the host provides.
     The buttons are used to select the value to put into the clicked
     cell (mouse interface). Their number and the preferred layout
     depend on the Sudoku's maximum value.</remarks>
    }
    procedure Initialize(aHost: ISudokuHostform);
  end;

  {!
  <summary>
   Interface for the object handling the data for a Sudoku, including
   the Undo stack. </summary>
  }
  ISudokuData = interface(IInterface)
  ['{C29A464D-135E-405A-BB90-03BE8EB4BB5E}']
    {!
    <summary>
     Add a named mark for the current undo stack state. </summary>
    <param name="aName">is the name of the mark</param>
    <exception cref="EPreconditionViolation">
     is raised if the aName is already in use</exception>
    }
    procedure AddMark(const aName: string);
    {!
    <summary>
     Check if the undo stack has entries </summary>
    <returns>
     true if the last action can be undone, false if the undo stack is
     empty.</returns>
    }
    function CanUndo: boolean;
    {!
    <summary>
     Empty the undo stack and discard all defined marks. </summary>
    }
    procedure ClearUndostack;
    {! Getter for the Bounds property }
    function GetBounds: ISudokuProperties;
    {! Getter for the Cell property }
    function GetCell(aCol, aRow: TSudokuCellIndex): ISudokuCell;
    {! Getter for the Events property }
    function GetEvents: ISudokuDataEvents;
    {!
    <summary>
     Fetch the names of the defined undo stack marks </summary>
    <param name="aList">is the list to add the names to, required</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aList is nil</exception>
    <remarks>
     Any previous content of aList is deleted first!</remarks>
    }
    procedure GetMarks(aList: TStrings);
    {!
    <summary>
     Check if the undo stack has marks defined </summary>
    <returns>
     true if there are marks we could revert to, false if not.</returns>
    }
    function HasMarks: boolean;
    {!
    <summary>
     Check if this is a Gosu type Sudoku </summary>
    }
    function IsGosu: boolean;
    {!
    <summary>
     Check if a value would be valid in a cell </summary>
    <returns>
     true if the value is OK for the cell, false if not</returns>
    <param name="aCol">is the cell's column index</param>
    <param name="aRow">is the cell's row index</param>
    <param name="aValue">is the value to test</param>
    }
    function IsValueValid(aCol, aRow: TSudokuCellIndex; aValue: TSudokuValue):
        boolean;
    {!
    <summary>
     Load the Sudoku data, including the undo stack, overwriting any
     prior content.  </summary>
    <param name="aReader">used to read the data from, required</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aReader is nil</exception>
    }
    procedure Load(aReader: TReader);
    {!
    <summary>
     Check if a stack mark with the given Name already exists. </summary>
    <returns>
     True if the mark exists, false if not /returns>
    <param name="aMark">is the mark name to check for.</param>
    <remarks>
     Mark names are not case-sensitive!</remarks>
    }
    function MarkExists(const aMark: string): boolean;
    {!
    <summary>
     Reset the data to empty, clear the undo stack. </summary>
    }
    procedure NewSudoku;
    {!
    <summary>
     Revert the state of the Sudoku to that identified by the named mark. </summary>
    <param name="aName">is the name of the mark</param>
    <exception cref="EPreconditionViolation">
     is raised if the named mark does not exist.</exception>
    }
    procedure RevertToMark(const aName: string);
    {!
    <summary>
     Store the Sudoku data, including the undo stack  </summary>
    <param name="aWriter">used to write the data to, required</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aWriter is nil</exception>
    }
    procedure Store(aWriter: TWriter);
    {!
    <summary>
     Undo the last change the user made to the Sudoku.</summary>
    <exception cref="EPreconditionViolation">
     is raised if the undo stack is empty</exception>
    }
    procedure Undo;
    {!
    <summary>
     Validate a Sudoku cell's column and row index </summary>
    <param name="aCol">is the cells column index</param>
    <param name="aRow">is the cells row index</param>
    <param name="aProcName">name of the calling method, used to
      compose the error message</param>
    <exception cref="ECellIndexOutOfBounds">
     is raised if aCol or aRow are not in the range 1 .. MaxValue </exception>
    }
    procedure ValidateCellCoord(aCol, aRow: TSudokuCellIndex; const aProcName:
        string);
    {!
    <value>
     Interface giving access to the Sudoku's dimensions.
    </value>}
    property Bounds: ISudokuProperties read GetBounds;
    {!
    <value>
     Interface for a cell of the Sudoku
    </value>}
    property Cell[aCol, aRow: TSudokuCellIndex]: ISudokuCell read GetCell;
    {!
    <value>
     Interface for the events an observer can use to react to changes
     to the Sudoku's state.
    </value>}
    property Events: ISudokuDataEvents read GetEvents;
  end;

  {!
  <summary>
   The UI will refer to the currently active helper through this
   interface. Most of the methods just delegate to the data storage
   methods of the same name, so clients need no knowledge of how
   the data is stored (Law of Demeter). </summary>
  }
  ISudokuHelper = interface(IInterface)
  ['{DB616905-F1C2-47FF-A137-B84DA9A416C6}']
    {!
    <summary>
     Add a named mark for the current undo stack state </summary>
    <param name="aName">is the name of the mark</param>
    <exception cref="EPreconditionViolation">
     is raised if the aName is already in use</exception>
    }
    procedure AddMark(const aName: string);
    {!
    <summary>
     Check if the undo stack has entries </summary>
    <returns>
     true if the last action can be undone, false if the undo stack is
     empty.</returns>
    }
    function CanUndo: boolean;
    {!
    <summary>
     Empty the undo stack and discard all defined marks. </summary>
    }
    procedure ClearUndostack;
    {! Getter for the Data property. }
    function GetData: ISudokuData;
    {! Getter for the Display property. }
    function GetDisplay: ISudokuDisplay;
    {! Getter for the Displayname property. }
    function GetDisplayname: string;
    {! Getter for the InputHandler property. }
    function GetInputHandler: ISudokuInputHandler;
    {!
    <summary>
     Fetch the names of the defined undo stack marks </summary>
    <param name="aList">is the list to add the names to, required</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aList is nil</exception>
    <remarks>
     Any previous content of aList is deleted first!</remarks>
    }
    procedure GetMarks(aList: TStrings);
    {!
    <summary>
     Check if the undo stack has marks defined </summary>
    <returns>
     true if there are marks we could revert to, false if not.</returns>
    }
    function HasMarks: boolean;
    {!
    <summary>
     Check if this is a Gosu type Sudoku </summary>
    }
    function IsGosu: boolean;
    {!
    <summary>
     Check if a stack mark with the given Name already exists. </summary>
    <returns>
     True if the mark exists, false if not /returns>
    <param name="aMark">is the mark name to check for.</param>
    <remarks>
     Mark names are not case-sensitive!</remarks>
    }
    function MarkExists(const aMark: string): boolean;
    {!
    <summary>
     Create a new empty Sudoku of the supported type </summary>
    <exception cref="EPreconditionViolation">
     is raised if this method is called before the display grid has
     been initialized.</exception>
    }
    procedure NewSudoku;
    {!
    <summary>
     Revert the state of the Sudoku to that identified by the named mark. </summary>
    <param name="Name">is the name of the mark</param>
    <exception cref="EPreconditionViolation">
     is raised if the named mark does not exist.</exception>
    }
    procedure RevertToMark(const Name: string);
    {!
    <summary>
     Undo the last change the user made to the Sudoku.</summary>
    <exception cref="EPreconditionViolation">
     is raised if the undo stack is empty</exception>
    }
    procedure Undo;
    {!
    <value>
      Interface for the object handling the data for the Sudoku
    </value>}
    property Data: ISudokuData read GetData;
    {!
    <value>
     Interface for the grid display
    </value>}
    property Display: ISudokuDisplay read GetDisplay;
    {!
    <value>
     String describing the Sudoku type the helper supports, for display
     in the UI selection dropdown.
    </value>}
    property Displayname: string read GetDisplayname;
    {!
    <value>
     Interface for the input handler
    </value>}
    property InputHandler: ISudokuInputHandler read GetInputHandler;

  end;

  {! Exception raised if validation of a cell's column or row index
    fails. }
  ECellIndexOutOfBounds = class(EInvalidParameter);


implementation

end.

