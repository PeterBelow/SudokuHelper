{!
<summary>
 This unit defines symbolic constants for most of the non-alphanumeric
  characters from the 7-bit ASCII character set, with a few additions
  from the Latin-1 extension.</summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2005-06-07<p>
 Version 1.1 created 2016-05-19, changed unit name to use the
 new qualified name syntax<p>
 Last modified       2016-05-19<p>
</history>
<copyright>Copyright 2009 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
}
unit PB.CharactersU;

interface


//NODOC-BEGIN
const
  Nul = #0;
  SOH = #1;
  STX = #2;
  ETX = #3;
  EOT = #4;
  ENQ = #5;
  ACK = #6;
  BEL = #7;
  BS  = #8;
  Backspace = #8;
  Tab = #9;
  LF  = #10;
  Linefeed = #10;
  VT  = #11;
  FF  = #12;
  Formfeed = #12;
  CR  = #13;
  CarriageReturn = #13;
  SO  = #14;
  SI  = #15;
  DLE = #16;
  DC1 = #17;
  DC2 = #18;
  DC3 = #19;
  DC4 = #20;
  NAK = #21;
  SYN = #22;
  ETB = #23;
  CAN = #24;
  EM  = #25;
  SUB = #26;
  ESC = #27;
  FS  = #28;
  GS  = #29;
  RS  = #30;
  US  = #31;
  Space = #32;
  AtSign = '@';
  DoubleQuote = '"';
  SingleQuote = '''';
  Comma = ',';
  Semicolon = ';';
  Colon = ':';
  Hyphen = '-';
  Underbar = '_';
  Dot = '.';
  Ampersand = '&';
  Percent = '%';
  Slash = '/';
  Backslash = '\';
  Equal = '=';
  Minus = '-';
  Plus  = '+';
  Hashmark = '#';
  Asterisk = '*';
  Tilde    = '~';
  Questionmark = '?';
  Exclamationmark = '!';
  Paragraph = '§';
  OpeningParanthesis = '(';
  ClosingParanthesis = ')';
  OpeningBracket = '[';
  ClosingBracket = ']';
  OpeningBrace   = '{';
  ClosingBrace   = '}';
  Dollar = '$';
  Euro   = '€';
  Pipe = '|';
  Greater = '>';
  Smaller = '<';
  Micron = 'µ';
  Sterling = '£';
  Yen   = '¥';
  Copyright = '©';
  RegisteredTrademark = '®';
  PlusMinus = '±';
  Dash = '­';
  Bullet = '•';
  Trademark = '™';
  Permille = '‰';
  Ellipsis = '…';
  CRLF = #13#10;
  NonBreakingSpace = #$A0;
  UTF16BOM = #$FEFF;
//NODOC-END


implementation

const
  {The following construct is just to allow Doc-O-matic to create a
   useful help topic for the constants without having to comment
   each individual symbol. }
  {!
    <property name="keyword" value="Nul" />
    <property name="keyword" value="SOH" />
    <property name="keyword" value="STX" />
    <property name="keyword" value="ETX" />
    <property name="keyword" value="EOT" />
    <property name="keyword" value="ENQ" />
    <property name="keyword" value="ACK" />
    <property name="keyword" value="BEL" />
    <property name="keyword" value="BS" />
    <property name="keyword" value="Backspace" />
    <property name="keyword" value="Tab" />
    <property name="keyword" value="LF" />
    <property name="keyword" value="Linefeed" />
    <property name="keyword" value="VT" />
    <property name="keyword" value="FF" />
    <property name="keyword" value="Formfeed" />
    <property name="keyword" value="CR" />
    <property name="keyword" value="CarriageReturn" />
    <property name="keyword" value="SO" />
    <property name="keyword" value="SI" />
    <property name="keyword" value="DLE" />
    <property name="keyword" value="DC1" />
    <property name="keyword" value="DC2" />
    <property name="keyword" value="DC3" />
    <property name="keyword" value="DC4" />
    <property name="keyword" value="NAK" />
    <property name="keyword" value="SYN" />
    <property name="keyword" value="ETB" />
    <property name="keyword" value="CAN" />
    <property name="keyword" value="EM" />
    <property name="keyword" value="SUB" />
    <property name="keyword" value="ESC" />
    <property name="keyword" value="FS" />
    <property name="keyword" value="GS" />
    <property name="keyword" value="RS" />
    <property name="keyword" value="US" />
    <property name="keyword" value="Space" />
    <property name="keyword" value="AtSign" />
    <property name="keyword" value="DoubleQuote" />
    <property name="keyword" value="SingleQuote" />
    <property name="keyword" value="Comma" />
    <property name="keyword" value="Semicolon" />
    <property name="keyword" value="Colon" />
    <property name="keyword" value="Hyphen" />
    <property name="keyword" value="Underbar" />
    <property name="keyword" value="Dot" />
    <property name="keyword" value="Ampersand" />
    <property name="keyword" value="Percent" />
    <property name="keyword" value="Slash" />
    <property name="keyword" value="Backslash" />
    <property name="keyword" value="Equal" />
    <property name="keyword" value="Minus" />
    <property name="keyword" value="Plus" />
    <property name="keyword" value="Hashmark" />
    <property name="keyword" value="Asterisk" />
    <property name="keyword" value="Tilde" />
    <property name="keyword" value="Questionmark" />
    <property name="keyword" value="Exclamationmark" />
    <property name="keyword" value="Paragraph" />
    <property name="keyword" value="OpeningParanthesis" />
    <property name="keyword" value="ClosingParanthesis" />
    <property name="keyword" value="OpeningBracket" />
    <property name="keyword" value="ClosingBracket" />
    <property name="keyword" value="OpeningBrace" />
    <property name="keyword" value="ClosingBrace" />
    <property name="keyword" value="Dollar" />
    <property name="keyword" value="Euro" />
    <property name="keyword" value="Pipe" />
    <property name="keyword" value="Greater" />
    <property name="keyword" value="Smaller" />
    <property name="keyword" value="Micron" />
    <property name="keyword" value="Sterling" />
    <property name="keyword" value="Yen" />
    <property name="keyword" value="Copyright" />
    <property name="keyword" value="RegisteredTrademark" />
    <property name="keyword" value="PlusMinus" />
    <property name="keyword" value="Dash" />
    <property name="keyword" value="Bullet" />
    <property name="keyword" value="Trademark" />
    <property name="keyword" value="Permille" />
    <property name="keyword" value="Ellipsis" />
    <property name="keyword" value="CRLF" />
    <property name="keyword" value="NonBreakingSpace" />
    <property name="keyword" value="UTF16BOM" />

    <summary>
    List of character constants defined by the unit
    </summary>
    <remarks>
    <code>
    Nul = #0;
    SOH = #1;
    STX = #2;
    ETX = #3;
    EOT = #4;
    ENQ = #5;
    ACK = #6;
    BEL = #7;
    BS  = #8;
    Backspace = #8;
    Tab = #9;
    LF  = #10;
    Linefeed = #10;
    VT  = #11;
    FF  = #12;
    Formfeed = #12;
    CR  = #13;
    CarriageReturn = #13;
    SO  = #14;
    SI  = #15;
    DLE = #16;
    DC1 = #17;
    DC2 = #18;
    DC3 = #19;
    DC4 = #20;
    NAK = #21;
    SYN = #22;
    ETB = #23;
    CAN = #24;
    EM  = #25;
    SUB = #26;
    ESC = #27;
    FS  = #28;
    GS  = #29;
    RS  = #30;
    US  = #31;
    Space = #32;
    AtSign = '@';
    DoubleQuote = '&quot;';
    SingleQuote = '''';
    Comma = ',';
    Semicolon = ';';
    Colon = ':';
    Hyphen = '-';
    Underbar = '_';
    Dot = '.';
    Ampersand = '&amp;';
    Percent = '%';
    Slash = '/';
    Backslash = '';
    Equal = '=';
    Minus = '-';
    Plus  = '+';
    Hashmark = '#';
    Asterisk = '*';
    Tilde    = '~';
    Questionmark = '?';
    Exclamationmark = '!';
    Paragraph = '§';
    OpeningParanthesis = '(';
    ClosingParanthesis = ')';
    OpeningBracket = '[';
    ClosingBracket = ']';
    OpeningBrace   = '{';
    ClosingBrace   = '&#125;';
    Dollar = '$';
    Euro   = '€';
    Pipe = '|';
    Greater = '&gt;';
    Smaller = '&lt;';
    Micron = 'µ';
    Sterling = '£';
    Yen   = '¥';
    Copyright = '©';
    RegisteredTrademark = '®';
    PlusMinus = '±';
    Dash = '­';
    Bullet = '•';
    Trademark = '™';
    Permille = '‰';
    Ellipsis = '…';
    CRLF = #13#10;
    NonBreakingSpace = #$A0;
    UTF16BOM = #$FEFF;
    </code>

    </remarks>
  }
  CharacterList = 'JUST FOR DOC-O-MATIC';

end.
