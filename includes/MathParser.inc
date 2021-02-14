/*
	SA-MP MathParser Include (v0.1.0)
	Copyright © 2012 RyDeR`
*/

#include <a_samp>

#if defined MathParser_INC
	#endinput
#else
	#define MathParser_INC
#endif

#define Math:: Math_
#define Parser:: Parser_

#if !defined PRECISION
	#define PRECISION 3
#endif

#define MAX_OPERATORS (32)
#define MAX_OPERATOR_LENGTH (8)
#define MAX_OPERATOR_FUNCTION_LENGTH (20)

#define MAX_CONSTANTS (32)
#define MAX_CONSTANT_LENGTH (20)

#define MAX_FUNCTIONS (32)
#define MAX_FUNCTION_LENGTH (16)
#define MAX_FUNCTION_FUNCTION_LENGTH (20)
#define MAX_FUNCTION_PARAMS (8)
#define MAX_FUNCTION_PARAMS_LENGTH (32)

#define Debug(%0,%1,%2) \
	printf("\n » [MathParser - " #%0 " @ " #%1 "] " %2)

#define Math_Operator%1(%2) \
	Float:%1_Op(%2); public Float:%1_Op(%2)
	
#define Math_Function%1(%2) \
	Float:%1_Fu(%2); public Float:%1_Fu(%2)

enum e_Assoc {
	LEFT_TO_RIGHT,
	RIGHT_TO_LEFT
};

enum e_Operator {
	Op_szOp[MAX_OPERATOR_LENGTH char],
	Op_szFunc[MAX_OPERATOR_FUNCTION_LENGTH char],
	Op_iPrecedence,
	e_Assoc: Op_iAssoc
};

enum e_Constant {
	Const_szConst[MAX_CONSTANT_LENGTH char],
	Float: Const_fValue
}

enum e_Function {
	Func_szName[MAX_FUNCTION_LENGTH char],
	Func_szFunc[MAX_FUNCTION_FUNCTION_LENGTH char],
	Func_iParams
};

enum e_Index {
	Operator,
	Constant,
	Function
};

enum e_Stack {
	Stk_iOpIdx,
	Stk_iPrecedence,
	e_Assoc: Stk_iAssoc,
	Float: Stk_fValue
};

enum e_Error {
	ERROR_NONE,
	ERROR_LOGICAL_VALUE,
	ERROR_LOGICAL_OPERATOR,
	ERROR_LOGICAL_PARANTHESES,
	ERROR_PARAMETER_FUNCTION
};

// Avoid warnings
static stock Float: Parser::Calculate(const Float: fValue1, const Float: fValue2, const iOpIdx);
static stock Float: Parser::ParseValue(const szExpr[], &e_Error: iError, &iIdx);
static stock Float: Parser::Evaluate(const szExpr[], &e_Error: iError, &iIdx);

static
	g_eiIndex[e_Index],
	
	g_aeOperator[MAX_OPERATORS][e_Operator],
	g_aeConstant[MAX_CONSTANTS][e_Constant],
	g_aeFunction[MAX_FUNCTIONS][e_Function]
;

MathParser(); public MathParser() { // Prevent crash from SYSREQ.C
	CallRemoteFunction("_", "");
}

stock Float: Math::ParseExpression(szExpr[], &e_Error: iError = ERROR_NONE, &iIdx = 0, const iSize = sizeof(szExpr)) {
	static
		bool: s_Init
	;
	if(!s_Init) {
		Math::AddOperator("E", "E", 25, RIGHT_TO_LEFT);
		Math::AddOperator("^", "Pow", 20, RIGHT_TO_LEFT);
		Math::AddOperator("*", "Mul", 15, LEFT_TO_RIGHT);
		Math::AddOperator("/", "Div", 15, LEFT_TO_RIGHT);
		Math::AddOperator("%", "Mod", 15, LEFT_TO_RIGHT);
		Math::AddOperator("+", "Add", 10, LEFT_TO_RIGHT);
		Math::AddOperator("-", "Sub", 10, LEFT_TO_RIGHT);
		
		Math::AddConstant("pi", 3.141592);
		Math::AddConstant("e", 2.718281);
		
		Math::AddFunction("log", "Log", 2);
		Math::AddFunction("sqrt", "Sqrt", 1);
		
		s_Init = !s_Init;
	}
	Parser::ReplaceConstants(szExpr, iSize);
	Parser::ReplaceFunctions(szExpr, iError, iSize);
	
	if(iError != ERROR_NONE) {
		Debug(Error, ParseExpression, "Something is wrong with your expression! \n");
		return 0.0;
	}
	return Parser::Evaluate(szExpr, iError, iIdx);
}

stock Math::AddFunction(const szName[], const szFunc[], const iParams) {
	if(strlen(szName) >= MAX_FUNCTION_LENGTH) {
		Debug(Error, AddFunction, "MAX_FUNCTION_LENGTH (%d) exceeded! \n", MAX_FUNCTION_LENGTH);
		return -1;
	}
	if(strlen(szFunc) >= MAX_FUNCTION_FUNCTION_LENGTH) {
		Debug(Error, AddFunction, "MAX_FUNCTION_FUNCTION_LENGTH (%d) exceeded! \n", MAX_FUNCTION_FUNCTION_LENGTH);
		return -1;
	}
	if(!(-1 < iParams < MAX_FUNCTION_PARAMS)) {
		Debug(Error, AddFunction, "MAX_FUNCTION_PARAMS (%d) exceeded! \n", MAX_FUNCTION_PARAMS);
		return -1;
	}
	new
		i = g_eiIndex[Function]
	;
	if(-1 < i < MAX_FUNCTIONS) {
		static
			s_szFunc[MAX_FUNCTION_FUNCTION_LENGTH]
		;
		format(s_szFunc, sizeof(s_szFunc), "%s_Fu", szFunc);
		
		if(funcidx(s_szFunc) != -1) {
			strpack(g_aeFunction[i][Func_szName], szName, MAX_FUNCTION_LENGTH char);
			strpack(g_aeFunction[i][Func_szFunc], s_szFunc, MAX_FUNCTION_FUNCTION_LENGTH char);
			
			g_aeFunction[i][Func_iParams] = iParams;
			
			do {
				g_eiIndex[Function]++;
			} while(g_aeFunction[g_eiIndex[Function]][Func_szName][0] != EOS);
			
			return i;
		} else {
			Debug(Error, AddFunction, "Unable to find functions function \"%s\"! \n", szFunc);
			return -1;
		}
	} else {
		Debug(Error, AddFunction, "MAX_FUNCTIONS (%d) exceeded! \n", MAX_FUNCTIONS);
		return -1;
	}
}

stock Math::RemoveFunction(const szName[]) {
	for(new i = 0; i < MAX_FUNCTIONS; ++i) {
		if(g_aeFunction[i][Func_szName][0] != EOS) {
			static
				s_szName[MAX_FUNCTION_LENGTH]
			;
			strunpack(s_szName, g_aeFunction[i][Func_szName], MAX_FUNCTION_LENGTH);
			
			if(!strcmp(s_szName, szName, false, MAX_FUNCTION_LENGTH)) {
				g_aeFunction[i][Func_szName][0] = EOS;
				
				if(i < g_eiIndex[Function]) {
					g_eiIndex[Function] = i;
				}
				return 1;
			}
		}
	}
	Debug(Error, RemoveFunction, "Unable to find function \"%s\"! \n", szName);
	return 0;
}

static stock Parser::ReplaceFunctions(szExpr[], &e_Error: iError, const iSize) {
	new
		szFormat[MAX_FUNCTION_PARAMS] = {
			'f', ...
		},
		szName[MAX_FUNCTION_LENGTH],
		szFunc[MAX_FUNCTION_FUNCTION_LENGTH],
		
		aszParams[MAX_FUNCTION_PARAMS][MAX_FUNCTION_PARAMS_LENGTH]
	;
	for(new i = 0; i < MAX_FUNCTIONS; ++i) {
		if(g_aeFunction[i][Func_szName][0] != EOS) {
			new
				iPos = -1
			;
			strunpack(szName, g_aeFunction[i][Func_szName], MAX_FUNCTION_LENGTH);
			
			while((iPos = strfind(szExpr, szName, false, (iPos + 1))) != -1) {
				new
					iParanthese = Parser::GetParantheseClosePos(szExpr, iPos, iSize),
					iParams
				;
				if(iParanthese != -1) {
					new
						iLen = strlen(szName)
					;
					Parser::ReplaceFunctions(szExpr[iPos + iLen + 1], iError, iParanthese);
					
					szExpr[iParanthese] = EOS;
					
					if(g_aeFunction[i][Func_iParams] > 1) {
						iParams = Parser::Explode(szExpr[iPos + iLen + 1], ",", aszParams);
					} else {
						strmid(aszParams[0], szExpr, iPos + iLen + 1, iParanthese);
						iParams++;
					}
					szExpr[iParanthese] = ')';
					
					if(iParams != g_aeFunction[i][Func_iParams]) {
						Parser::PrintErrors((iError = ERROR_PARAMETER_FUNCTION), -1);
						return 0;
					}
					while(iParams--) {
						new
							iTemp
						;
						format(aszParams[iParams], MAX_FUNCTION_PARAMS_LENGTH, "%." #PRECISION "f", Parser::Evaluate(aszParams[iParams], iError, iTemp));
					}
					iParams = (g_aeFunction[i][Func_iParams] + 2) << 2;
					
					new
						iIdx = g_aeFunction[i][Func_iParams],
						Float: fValue
					;
					while(iIdx--) {
						fValue = floatstr(aszParams[iIdx]);
						
						#emit LOAD.S.PRI fValue
						#emit HEAP 4
						#emit STOR.I
						#emit PUSH.ALT
					}
					szFormat[g_aeFunction[i][Func_iParams]] = EOS;
					#emit PUSH.ADR szFormat
					
					strunpack(szFunc, g_aeFunction[i][Func_szFunc], MAX_FUNCTION_FUNCTION_LENGTH);
					#emit PUSH.ADR szFunc
					#emit PUSH.S iParams
					
					#emit SYSREQ.C CallRemoteFunction
					#emit STOR.S.PRI fValue
					
					szFormat[g_aeFunction[i][Func_iParams]] = 'f';
					
					iParams += 4;
					
					#emit LCTRL 4
					#emit LOAD.S.ALT iParams
					#emit ADD
					#emit SCTRL 4
					
					iParams = (g_aeFunction[i][Func_iParams] << 2);
					
					#emit LCTRL 2
					#emit LOAD.S.ALT iParams
					#emit ADD
					#emit SCTRL 2
					
					strdel(szExpr, iPos, iParanthese + 1);
					strins(szExpr, Parser::ToString(fValue), iPos, iSize);
				} else {
					Parser::PrintErrors((iError = ERROR_LOGICAL_PARANTHESES), -1);
					return 0;
				}
			}
		}
	}
	return 1;
}

stock Math::AddConstant(const szConst[], const Float: fValue) {
	if(strlen(szConst) >= MAX_CONSTANT_LENGTH) {
		Debug(Error, AddConstant, "MAX_CONSTANT_LENGTH (%d) exceeded! \n", MAX_CONSTANT_LENGTH);
		return -1;
	}
	new
		i = g_eiIndex[Constant]
	;
	if(-1 < i < MAX_CONSTANTS) {
		strpack(g_aeConstant[i][Const_szConst], szConst, MAX_CONSTANT_LENGTH char);
		g_aeConstant[i][Const_fValue] = fValue;
		
		do {
			g_eiIndex[Constant]++;
		} while(g_aeConstant[g_eiIndex[Constant]][Const_szConst][0] != EOS);
			
		return i;
	} else {
		Debug(Error, AddConstant, "MAX_CONSTANTS (%d) exceeded! \n", MAX_CONSTANTS);
		return -1;
	}
}

stock Math::RemoveConstant(const szConst[]) {
	for(new i = 0; i < MAX_CONSTANTS; ++i) {
		if(g_aeConstant[i][Const_szConst][0] != EOS) {
			static
				s_szConst[MAX_CONSTANT_LENGTH]
			;
			strunpack(s_szConst, g_aeConstant[i][Const_szConst], MAX_CONSTANT_LENGTH);
			
			if(!strcmp(s_szConst, szConst, false, MAX_CONSTANT_LENGTH)) {
				g_aeConstant[i][Const_szConst][0] = EOS;
				
				if(i < g_eiIndex[Constant]) {
					g_eiIndex[Constant] = i;
				}
				return 1;
			}
		}
	}
	Debug(Error, RemoveConstant, "Unable to find constant \"%s\"! \n", szConst);
	return 0;
}

static stock Parser::ReplaceConstants(szExpr[], const iSize = sizeof(szExpr)) {
	for(new i = 0; i < MAX_CONSTANTS; ++i) {
		if(g_aeConstant[i][Const_szConst][0] != EOS) {
			static
				s_szConst[MAX_CONSTANT_LENGTH],
				s_iPos,
				s_iLen
			;
			strunpack(s_szConst, g_aeConstant[i][Const_szConst], MAX_CONSTANT_LENGTH);

			s_iPos = -1;
			s_iLen = strlen(s_szConst);
			
			while((s_iPos = strfind(szExpr, s_szConst, false, (s_iPos + 1))) != -1) {
				if(s_iPos < s_iLen || s_iPos >= MAX_CONSTANT_LENGTH) {
					goto SkipCheck;
				}
				if(!(Parser::IsAlpha(szExpr[s_iPos - 1]) || Parser::IsAlpha(szExpr[s_iPos + s_iLen]))) {
					SkipCheck: {
						strdel(szExpr, s_iPos, s_iPos + s_iLen);
						strins(szExpr, Parser::ToString(g_aeConstant[i][Const_fValue]), s_iPos, iSize);
					}
				}
			}
		}
	}
}

stock Math::AddOperator(const szOp[], const szFunc[], const iPrecedence, const e_Assoc: iAssoc) {
	if(strlen(szOp) >= MAX_OPERATOR_LENGTH) {
		Debug(Error, AddOperator, "MAX_OPERATOR_LENGTH (%d) exceeded! \n", MAX_OPERATOR_LENGTH);
		return -1;
	}
	if(strlen(szFunc) >= MAX_OPERATOR_FUNCTION_LENGTH) {
		Debug(Error, AddOperator, "MAX_OPERATOR_FUNCTION_LENGTH (%d) exceeded! \n", MAX_OPERATOR_FUNCTION_LENGTH);
		return -1;
	}
	new
		i = g_eiIndex[Operator]
	;
	if(-1 < i < MAX_OPERATORS) {
		static
			s_szFunc[MAX_OPERATOR_FUNCTION_LENGTH]
		;
		format(s_szFunc, sizeof(s_szFunc), "%s_Op", szFunc);
		
		if(funcidx(s_szFunc) != -1) {
			strpack(g_aeOperator[i][Op_szOp], szOp, MAX_OPERATOR_LENGTH char);
			strpack(g_aeOperator[i][Op_szFunc], s_szFunc, MAX_OPERATOR_FUNCTION_LENGTH char);
			
			g_aeOperator[i][Op_iPrecedence] = iPrecedence;
			g_aeOperator[i][Op_iAssoc] = iAssoc;
			
			do {
				g_eiIndex[Operator]++;
			} while(g_aeOperator[g_eiIndex[Operator]][Op_szOp][0] != EOS);
			
			return i;
		} else {
			Debug(Error, AddOperator, "Unable to find operator function \"%s\"! \n", szFunc);
			return -1;
		}
	} else {
		Debug(Error, AddOperator, "MAX_OPERATORS (%d) exceeded! \n", MAX_OPERATORS);
		return -1;
	}
}

stock Math::RemoveOperator(const szOp[]) {
	for(new i = 0; i < MAX_OPERATORS; ++i) {
		if(g_aeOperator[i][Op_szOp][0] != EOS) {
			if(!strcmp(g_aeOperator[i][Op_szOp], szOp, false, MAX_OPERATOR_LENGTH)) {
				g_aeOperator[i][Op_szOp][0] = EOS;
				
				if(i < g_eiIndex[Operator]) {
					g_eiIndex[Operator] = i;
				}
				return 1;
			}
		}
	}
	Debug(Error, RemoveOperator, "Unable to find operator \"%s\"! \n", szOp);
	return 0;
}

static stock Float: Parser::Evaluate(const szExpr[], &e_Error: iError, &iIdx) {
	new
		iStack,
		eStack[e_Stack],
		aeStack[MAX_OPERATORS][e_Stack],
		Float: fValue = Parser::ParseValue(szExpr, iError, iIdx)
	;
	aeStack[0][Stk_iOpIdx] = -1;
	
	while(iStack > -1) {
		if(iError != ERROR_NONE) {
			return 0.0;
		}
		Parser::ParseOperator(szExpr, iError, iIdx, eStack);
		
		while(eStack[Stk_iPrecedence] < aeStack[iStack][Stk_iPrecedence] || (eStack[Stk_iPrecedence] == aeStack[iStack][Stk_iPrecedence] && eStack[Stk_iAssoc] == LEFT_TO_RIGHT)) {
			if(aeStack[iStack][Stk_iOpIdx] == -1) {
				return fValue;
			}
			fValue = Parser::Calculate(aeStack[iStack][Stk_fValue], fValue, aeStack[iStack][Stk_iOpIdx]);
			iStack--;
		}
		aeStack[++iStack][Stk_iOpIdx] = eStack[Stk_iOpIdx];
		aeStack[iStack][Stk_iPrecedence] = eStack[Stk_iPrecedence];
		aeStack[iStack][Stk_iAssoc] = eStack[Stk_iAssoc];
		aeStack[iStack][Stk_fValue] = fValue;
			
		fValue = Parser::ParseValue(szExpr, iError, iIdx);
	}
	return 0.0;
}

static stock Float: Parser::Calculate(const Float: fValue1, const Float: fValue2, const iOpIdx) {
	if(g_aeOperator[iOpIdx][Op_szOp][0] != EOS) {
		static
			s_szFunc[MAX_OPERATOR_FUNCTION_LENGTH]
		;
		strunpack(s_szFunc, g_aeOperator[iOpIdx][Op_szFunc], MAX_OPERATOR_FUNCTION_LENGTH);
		
		return Float: CallRemoteFunction(s_szFunc, "ff", fValue1, fValue2);
	}
	return 0.0;
}

static stock Parser::ParseOperator(const szExpr[], &e_Error: iError, &iIdx, eStack[e_Stack]) {
	Parser::StripSpaces(szExpr, iIdx);
	
	eStack[Stk_iOpIdx] = 0;
	eStack[Stk_iPrecedence] = 0;
	eStack[Stk_iAssoc] = LEFT_TO_RIGHT;

	if(szExpr[iIdx] == ')') {
		return 1;
	}
	if(iError == ERROR_NONE) {
		for(new i = 0, iLen = 0; i < MAX_OPERATORS; ++i) {
			static
				s_szOp[MAX_OPERATOR_LENGTH]
			;
			strunpack(s_szOp, g_aeOperator[i][Op_szOp], MAX_OPERATOR_LENGTH);
				
			if(s_szOp[0] == szExpr[iIdx]) {
				if(!strcmp(szExpr[iIdx], s_szOp, false, (iLen = strlen(s_szOp)))) {
					iIdx += iLen;
						
					eStack[Stk_iOpIdx] = i;
					eStack[Stk_iPrecedence] = g_aeOperator[i][Op_iPrecedence];
					eStack[Stk_iAssoc] = g_aeOperator[i][Op_iAssoc];
					return 1;
				}
			}
		}
	}
	Parser::PrintErrors((iError = ERROR_LOGICAL_OPERATOR), iIdx);
	return 0;
}

static stock Float: Parser::ParseValue(const szExpr[], &e_Error: iError, &iIdx) {
	Parser::StripSpaces(szExpr, iIdx);
	
	if(iError == ERROR_NONE) {
		switch(szExpr[iIdx]) {
			case '0' .. '9': {
				switch(szExpr[iIdx + 1]) {
					case 'x', 'X': {
						iIdx += 2;
						
						new
							iValue
						;
						while(('a' <= szExpr[iIdx] <= 'f' || 'A' <= szExpr[iIdx] <= 'F' || ('0' <= szExpr[iIdx] <= '9'))) {
							switch(szExpr[iIdx]) {
								case 'a' .. 'f': {
									iValue = (iValue << 4) + (10 + szExpr[iIdx] - 'a');
								}
								case 'A' .. 'F': {
									iValue = (iValue << 4) + (10 + szExpr[iIdx] - 'A');
								}
								case '0' .. '9': {
									iValue = (iValue << 4) + (szExpr[iIdx] - '0');
								}
							}
							iIdx++;
						}
						return float(iValue);
					}
					case 'b', 'B': {
						iIdx += 2;
						
						new
							iValue
						;
						while(('0' <= szExpr[iIdx] <= '1')) {
							iValue = (iValue << 1) | (szExpr[iIdx++] - '0');
						}
						return float(iValue);
					}
					default: {
						new
							Float: fValue,
							Float: fScale
						;
						while(('0' <= szExpr[iIdx] <= '9' || szExpr[iIdx] == '.')) {
							if(szExpr[iIdx] == '.') {
								fScale = 1.0;
							} else {
								fValue = (fValue * 10.0) + (szExpr[iIdx] - '0');
								fScale *= 10.0;								
							}
							iIdx++;
						}
						return fValue / ((fScale != 0.0) ? (fScale) : (1.0));
					}
				}
			}
			case '(': {
				iIdx++;
				
				new
					Float: fValue = Parser::Evaluate(szExpr, iError, iIdx)
				;
				Parser::StripSpaces(szExpr, iIdx);
				
				if(szExpr[iIdx] != ')') {
					Parser::PrintErrors((iError = ERROR_LOGICAL_PARANTHESES), iIdx);
					return 0.0;
				}
				iIdx++;
				
				return fValue;
			}
			case '+': {
				iIdx++;
				return Parser::ParseValue(szExpr, iError, iIdx);
			}
			case '-': {
				iIdx++;
				return -Parser::ParseValue(szExpr, iError, iIdx);
			}
			default: {
				Parser::PrintErrors((iError = ERROR_LOGICAL_VALUE), iIdx);
			}
		}
	}
	return 0.0;
}

static stock Parser::GetParantheseClosePos(szExpr[], iPos, const iSize) {
	new
		iOpened,
		iClosed
	;
	while(iPos < iSize-1) {
		if(szExpr[iPos] == '(') {
			iOpened++;
		} else if(szExpr[iPos] == ')') {
			iClosed++;
			
			if(iOpened == iClosed) {
				break;
			}
		}
		++iPos;
	}
	if(iOpened != iClosed) {
		return -1;
	}
	return iPos;
}

static stock Parser::Explode(szSrc[], const szDelim[], aszDest[][], iSize = sizeof(aszDest), iLen = sizeof(aszDest[])) { // Slice
	new
		iPos = -1,
		iLastPos,
		i
	;
	goto LoopEnd;
    
	do {
		strcat((aszDest[i][0] = EOS, aszDest[i]), szSrc[iLastPos], min(iLen, iPos - iLastPos + 1));
		
		if (++i >= iSize)
			break;
        
	LoopEnd:
		iLastPos = ++iPos;
	} while((iPos = strfind(szSrc, szDelim, false, iPos)) != -1);
    
	if(i < iSize) {
		strcat((aszDest[i][0] = EOS, aszDest[i++]), szSrc[iLastPos], iLen);
	}
	return i;
}

static stock Parser::PrintErrors(const e_Error: iError, const iIdx) {
	switch(iError) {
		case ERROR_LOGICAL_VALUE: {
			Debug(Syntax Error, Parsing, "Invalid value found at index %d! \n", iIdx);
		}
		case ERROR_LOGICAL_OPERATOR: {
			Debug(Syntax Error, Parsing, "Invalid operator found at index %d! \n", iIdx);
		}
		case ERROR_LOGICAL_PARANTHESES: {
			Debug(Syntax Error, Parsing, "Invalid paranthese logic found at index %d! \n", iIdx);
		}
		case ERROR_PARAMETER_FUNCTION: {
			Debug(Syntax Error, Parsing, "Invalid parameters found in a function! \n");
		}
	}
}

static stock Parser::StripSpaces(const szInput[], &iIdx) {
	while(Parser::IsSpace(szInput[iIdx]) != 0) {
		iIdx++;
	}
}

static stock Parser::IsSpace(const iChar) {
	switch(iChar) {
		case ' ', '\n', '\r', '\t': {
			return 1;
		}
	}
	return 0;
}

static stock Parser::IsAlpha(const iChar) {
	switch(iChar) {
		case 'a' .. 'z', 'A' .. 'Z': {
			return 1;
		}
	}
	return 0;
}

static stock Parser::ToString(const Float: fValue) {
	static
		szValue[16]
	;
	format(szValue, sizeof(szValue), "%." #PRECISION "f", fValue);
	return szValue;
}

Math::Operator E(const Float: fValue, const Float: fExponent) {
	return fValue * floatpower(10.0, fExponent);
}

Math::Operator Pow(const Float: fValue1, const Float: fValue2) {
	return floatpower(fValue1, fValue2);
}

Math::Operator Mul(const Float: fValue1, const Float: fValue2) {
	return fValue1 * fValue2;
}

Math::Operator Div(const Float: fValue1, const Float: fValue2) {
	return fValue1 / fValue2;
}

Math::Operator Mod(const Float: fValue1, const Float: fValue2) {
	return fValue1 - fValue2 * floatround((fValue1 / fValue2), floatround_floor);
}

Math::Operator Add(const Float: fValue1, const Float: fValue2) {
	return fValue1 + fValue2;
}

Math::Operator Sub(const Float: fValue1, const Float: fValue2) {
	return fValue1 - fValue2;
}

Math::Function Log(const Float: fValue, const Float: fBase) {
	return floatlog(fValue, fBase);
}

Math::Function Sqrt(const Float: fValue) {
	return floatsqroot(fValue);
}