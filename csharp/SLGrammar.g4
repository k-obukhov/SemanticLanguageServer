/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

grammar SLGrammar;

// Базовые символы и имена
Colon: ':';
Semicolon: ';';
Comma: ',';
Point: '.';

Variable: 'variable';
Const: 'const';
Length: 'length';
Let: 'let';
Return: 'return';
Input: 'input';
Output: 'output';
Call: 'call';

If: 'if';
Then: 'then';
Else: 'else';
While: 'while';
Repeat: 'repeat';
Elseif: 'elseif';
Do: 'do';

Raw: 'raw';

// Арифметика и булевы токены
AddOp: '+';
SubOp: '-';
MulOp: '*';
DivOp: '/';
ModOp: '%';

BoolOr: '||';
BoolAnd: '&&';

BoolEq: '==';
BoolNeq: '!=';
BoolG: '>';
BoolL: '<';
BoolGeq: '>=';
BoolLeq: '<=';
BoolNot: '!';


// Объявление и импорт модуля
ModuleToken: 'module';
ImportToken: 'import';

// Начало и конец (конец используется ещё и в условиях/циклах/функциях)
Start: 'start';
End: 'end';

Function: 'function';
Procedure: 'procedure';

// круглые и квадратные скобки
LBrace: '(';
RBrace: ')';

LSBrace: '[';
RSBrace: ']';

AssignToken: ':='; // Присваивание

// ТИПЫ
fragment Integer: 'integer'; // | 'int'
fragment Real: 'real';
fragment Character: 'character'; // | 'char'
fragment Boolean: 'boolean'; // | 'bool'

typeName: scalarType | arrayType;
scalarType: simpleType | functionalType;
functionalType: procedureType | functionType; // Функциональный тип = процедуры и функции
simpleType : SimpleType; // Встроенные типы 

procedureType: Procedure functionalArgList Colon typeName; // Тип функция
functionType: Function functionalArgList;                // Тип процедура

functionalArgList: LBrace (functionalArg(Comma functionalArg) | /* nothing */) RBrace;
functionalArg: FunctionArgModifier typeName;

ArrayToken: 'array'; // Массивный тип
arrayType: ArrayToken (arrayDimention)+ scalarType;
arrayDimention : LSBrace RSBrace;

FunctionArgModifier : ArgValModifier | ArgRefModifier ; // Передача аргументов в функцию по значению и ссылке
fragment ArgValModifier: 'val';
fragment ArgRefModifier: 'ref';

AccessModifier: PublicModifier | PrivateModifier; // Модификаторы доступа
fragment PublicModifier: 'public';
fragment PrivateModifier: 'private';

// Работа с модулями тут =
start: moduleImportList module;
moduleImportList: (moduleImport | raw)*;
moduleImport: ImportToken Id;
module: ModuleToken Id moduleDeclare moduleEntry;

moduleDeclare: (functionDeclare | procedureDeclare | raw)*; // Определение модуля 
functionDeclare: AccessModifier Function functionalDeclareArgList Colon typeName Id statementSeq End; // Функции
procedureDeclare: AccessModifier Procedure functionalDeclareArgList Id statementSeq End; // Процедура

functionalDeclareArgList : LBrace (functionalDeclareArg (Comma functionalDeclareArg)* | /* нет аргументов */ )  RBrace; 

functionalDeclareArg : FunctionArgModifier typeName Id;

moduleEntry: Start statementSeq End Id Point;

statementSeq: (statement | raw)*;

statement: simpleStatement | complexStatement;

simpleStatement: (declare | let | input | output | return_val | call) Semicolon; // Операторы
complexStatement: if_cond | while_cond | repeat;

declare: constDeclare | varDeclare; // Определение констант и переменных
varDeclare: scalarDeclare | arrayDeclare;

// Определение констант и переменных
// Константы -- простые типы языка (на текущий момент)

constDeclare: Const simpleType Id AssignToken (mathExpression | boolExpression);
scalarDeclare: Variable scalarType Id (AssignToken mathExpression | AssignToken boolExpression);
arrayDeclare: Variable arrayDeclareType Id;

arrayDeclareType: ArrayToken (arrayDeclareDimention)+ scalarType;
arrayDeclareDimention: LSBrace mathExpression RSBrace;
arrayElement: Id (arrayDeclareDimention)+;
arrayLenProperty: Id Point Length LBrace IntValue RBrace;

let: Let (simpleLet | arrayLet);
simpleLet : Id AssignToken mathExpression | Id AssignToken boolExpression | Id AssignToken let;
arrayLet: arrayElement AssignToken mathExpression | arrayElement AssignToken boolExpression | arrayElement AssignToken let;

return_val: Return (exp)?;
input: Input (id | arrayElement);
output: Output outputArgument (Comma outputArgument)*;
outputArgument: StringLiteral | exp;

call: Call id LBrace callArgList RBrace;
callArgList: (callArg (Comma callArg)*) | /*nothing*/;
callArg: exp; // Некое выражение в аргументе

call_func: id LBrace callArgList RBrace;

// Условия
if_cond : If LBrace boolExpression RBrace Then statementSeq End Semicolon #IfSingle
   | If LBrace boolExpression RBrace Then statementSeq Else statementSeq End Semicolon #IfElse
   | If LBrace boolExpression RBrace Then statementSeq (Elseif LBrace boolExpression RBrace Then statementSeq)+ Else statementSeq End Semicolon #IfElseIfElse
   ;

while_cond: While LBrace boolExpression RBrace Do statementSeq End Semicolon;
repeat: Repeat statementSeq While LBrace boolExpression RBrace;

// Разбор математических правил

mathExpression
	: mathTerm #MathExpEmpty
	| mathTerm AddOp mathExpression #MathExpSum 
	| mathTerm SubOp mathExpression #MathExpSub
	;

mathTerm
	: mathFactor #MathTermEmpty
	| mathFactor MulOp mathTerm #MathTermMul 
	| mathFactor DivOp mathTerm #MathTermDiv 
	| mathFactor ModOp mathTerm #MathTermMod
	;

mathFactor
	: expAtom #MathFactorEmpty
	| LBrace mathExpression RBrace #MathFactorBrackets
	| AddOp mathFactor #MathFactorUnaryPlus
	| SubOp mathFactor #MathFactorUnaryMinus
	;

// Разбор булевых выражений

boolExpression
	: boolAnd #BoolOrEmpty
	| boolAnd BoolOr boolExpression #LogicOr
	;

boolAnd
	: boolEquality #BoolAndEmpty
	| boolEquality BoolAnd boolAnd #LogicAnd
	;

boolEquality
	: boolInequality #BoolEqualityEmpty
	| mathExpression BoolEq mathExpression #MathEqual
	| boolInequality BoolEq boolEquality #BoolEqual
	| mathExpression BoolNeq mathExpression #MathNotEqual
	| boolInequality BoolNeq boolEquality #BoolNotEqual 
	;

boolInequality
	: boolFactor #BoolInequalityEmpty
	| mathExpression BoolG mathExpression #Bigger
	| mathExpression BoolL mathExpression #Lesser
	| mathExpression BoolGeq mathExpression #BiggerOrEqual
	| mathExpression BoolLeq mathExpression #LesserOrEqual
	;

boolFactor
	: expAtom #BoolAtomEmpty 
	| BoolNot expAtom #Not 
	| LBrace boolExpression RBrace #BoolAtomBrackets 
	| BoolNot LBrace boolExpression RBrace #BoolAtomBracketsNot
	;

expAtom: call | arrayLenProperty | arrayElement | id | (IntValue | RealValue | BoolValue) | call_func;
// Точки -- для указания связт модуль-функция
id: (Id Point)? Id;
SimpleType: Real | Integer | Boolean | Character;

exp: mathExpression | boolExpression;

raw: 'raw' any End; // Вставка целевого кода -- мы же не будем писать стандартные модули на чистом семантике!
any: (.)*?;

// Многие простые типы-константы

fragment Digit: [0-9]; // цифра

IntValue: Digit+; // Целое число
RealValue: Digit*Point?Digit+([eE][-+]?Digit+)?; // Вещественное значение
BoolValue: 'true' | 'false'; // Булево значение

Id: [_a-zA-Z][_a-zA-Z0-9]*; // Идентификатор

StringLiteral:	'"' StringCharacter* '"'; // Строковый литерал
fragment StringCharacter: ~["] | EscapeSequence; // Символ
fragment EscapeSequence : '\\' [btnfr"'\\]; // escape-символы типа \n \t ... либо группа 1 символа

Comment: ('//' ~[\r\n]* | '/*' .*? '*/') -> skip;
Ws: [ \t\r\n] -> skip;