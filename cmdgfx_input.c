#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <windows.h>

// Compilation: gcc -o cmdgfx_input.exe -O2 cmdgfx_input.c
// TODO:	1. Check for CLICKS/RCLICKS?
//			2. Make sure sent event includes doubleclicks, sums of wheel, horizontal wheel?
//			3. Mouse wheel reporting not working on Win10. Seems wrong on Win7 too, mouse coordinates get messed up. May be API bug.

int MouseClicked(MOUSE_EVENT_RECORD mer) {
	static int bReportNext = 0;
	int res = 0;

	switch(mer.dwEventFlags) {
		case DOUBLE_CLICK: case MOUSE_WHEELED:	bReportNext = 1; res = 1; break;
		
		case 0: case MOUSE_MOVED:
			if(mer.dwButtonState & FROM_LEFT_1ST_BUTTON_PRESSED || mer.dwButtonState & RIGHTMOST_BUTTON_PRESSED) {
				bReportNext = 1;
				res = 1;
			} else if (bReportNext) {
				bReportNext = 0;
				res = 1;
			} else {
				bReportNext = 0;
				res = 0;
			}
			break;
		default:
			break;
	}
		
	return res;
}

int MouseEventProc(MOUSE_EVENT_RECORD mer, char *output) {
	int res;
	res = (mer.dwMousePosition.X << 7) | (mer.dwMousePosition.Y << 15);

	switch(mer.dwEventFlags) {
		case 0: case DOUBLE_CLICK: case MOUSE_MOVED:
			//printf("GOT: %d %d\n",mer.dwButtonState, mer.dwEventFlags);
			if(mer.dwButtonState & FROM_LEFT_1ST_BUTTON_PRESSED) {
				res |= 2;
				if (mer.dwEventFlags == DOUBLE_CLICK)
					res |= 8;
			}
			if(mer.dwButtonState & RIGHTMOST_BUTTON_PRESSED) {
				res |= 4;
				if (mer.dwEventFlags == DOUBLE_CLICK)
					res |= 16;			}
			break;
		case MOUSE_WHEELED:
			if ((int)mer.dwButtonState < 0)
				res |= 32;
			else
				res |= 64;
			break;
		default:
			break;
	}
	
	res |= 1;

	if (output) {
		sprintf(output, "MOUSE_EVENT 1 X %d Y %d LEFT %d RIGHT %d LEFT_DOUBLE %d RIGHT_DOUBLE %d WHEEL %d",
							mer.dwMousePosition.X, mer.dwMousePosition.Y, (res & 2)>0, (res & 4)>0, (res & 8)>0, (res & 16)>0, (res & 32)>0? 1: (res & 64)>0? -1 : 0);
	}
	
	return res;
}

BOOLEAN nanosleep(LONGLONG ns){
    HANDLE timer;
    LARGE_INTEGER li;

    if(!(timer = CreateWaitableTimer(NULL, TRUE, NULL)))
        return FALSE;
    li.QuadPart = -ns;
    if(!SetWaitableTimer(timer, &li, 0, NULL, NULL, FALSE)){
        CloseHandle(timer);
        return FALSE;
    }
    WaitForSingleObject(timer, INFINITE);
    CloseHandle(timer);
    return TRUE;
}

BOOLEAN millisleep(LONGLONG ms){
	return nanosleep(ms * 10000);
}

long long milliseconds_now(void) {
	static LARGE_INTEGER s_frequency;
	static BOOL s_use_qpc;

	s_use_qpc = QueryPerformanceFrequency(&s_frequency);
	if (s_use_qpc) {
		LARGE_INTEGER now;
		QueryPerformanceCounter(&now);
		return (1000LL * now.QuadPart) / s_frequency.QuadPart;
	} else {
		return GetTickCount();
	}
}

void process_waiting(int bWait, int waitTime, int bSleepingWait) { 
	static long long lastTime = -1;

	if (bWait==1 && waitTime > 0) {
		long long sT = milliseconds_now();
		if (bSleepingWait)
			millisleep(waitTime);
		else
			while (milliseconds_now() < sT + waitTime) ;
	}
	
	if (bWait==2 && waitTime > 0) {
		
		if (lastTime >= 0) {
			if (milliseconds_now() >= lastTime) {
			if (bSleepingWait) {
				int sleepTime = lastTime + waitTime - milliseconds_now();
				if (sleepTime > 0)
					millisleep(sleepTime);
			} else
				while (milliseconds_now() < lastTime + waitTime) ;
			}
		}
		lastTime = milliseconds_now();
	}
}

char g_padding[1060], g_sizeString[64];
int g_bReportSize = 0, g_bSizeChanged = 0, g_consoleWidth, g_consoleHeight;

int forward_event(int bSendNoEvent, int bMouse, int retVal, char *out, int bPadding, int bIncludeSize) {
	int bOkToForward = 1;
	
	if (!bSendNoEvent && !bMouse && retVal == 0)
		bOkToForward = 0;
	if (!bSendNoEvent && bMouse && retVal < 0)
		bOkToForward = 0;
	
	g_sizeString[0] = 0;
		
	if (bOkToForward) {

		if (g_bReportSize && bIncludeSize) {
			sprintf(g_sizeString, "%sRESIZE_EVENT %d W %d H %d", out == NULL || out[0] == 0? "" : "  ", g_bSizeChanged, g_consoleWidth, g_consoleHeight);
		}
	
		if (bPadding) g_padding[1020 - strlen(out) - strlen(g_sizeString)] = 0; 
		
		if (out)
			printf("%s%s %s\n", out, g_sizeString, bPadding == 0? "" : g_padding);
		else
			printf("%d\n", retVal);
		
		if (bPadding) g_padding[1020 - strlen(out) - strlen(g_sizeString)] = '-';
		
		return 1;
	}
	
	return 0;
}
	
HANDLE GetInputHandle() {
	return CreateFile("CONIN$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
}

HANDLE GetOutputHandle() {
	return CreateFile("CONOUT$", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
}

void GetDim(HANDLE conout) {
	CONSOLE_SCREEN_BUFFER_INFO screenBufferInfo;
	GetConsoleScreenBufferInfo(conout, &screenBufferInfo);
	g_consoleWidth = screenBufferInfo.srWindow.Right - screenBufferInfo.srWindow.Left + 1;
	g_consoleHeight = screenBufferInfo.srWindow.Bottom - screenBufferInfo.srWindow.Top + 1;
}	
	
int main(int argc, char *argv[]) {
	int bReadKey = 0, bWaitKey = 0, bMouse = 0, mouseWait = -1, bIgnoreInputFlagsFile = 0;
	int bWait = 0, waitTime = 0;
	int bSleepingWait = 0;
	int bSendNoEvent = 0, bSendKeyUp = 0;
	int bSendAll = 0, bPadding = 0, bIgnoreTitleComm = 0;
	char sFlags[256];
	char sEventOutput[256] = "";
	char sMouseOutput[256] = "";
	char sTitleBuffer[1024] = "";
	char sTempTitleBuffer[1024] = "";
	char sKeyOutput[256] = "";
	int i, j, retVal = 0;
	int bServer = 1;
	int eventCount;
	char *pch;
	DWORD fdwMode, oldfdwMode;
	HANDLE h_stdin, h_stdout;

	if (argc < 2 || (argc > 1 && strcmp(argv[1], "/?") == 0)) {
		printf("\nUsage: cmdgfx_input [flags]\n\n[flags]: 'k' forward last keypress, 'K' wait for/forward key, 'wn/Wn' wait/await n ms, 'm[wait]' forward key/PRESSED mouse events with optional wait, 'M[wait]' forward key/ALL mouse events with optional wait, 'z' sleep instead of busy wait, 'u' enable forwarding key-up events for M/m flag, 'n' send non-events, 'A' send all events, possibly several per wait (combined special keys not available), 'x' pad each message to be 1024 bytes, 'i' ignore inputflags.dat, 'I' ignore title flags, 'R' report window size changes.\n\nFlags can be modified during runtime by writing to 'inputflags.dat'. Precede a flag with '-' to cancel a previously set flag. Exit the server by including a 'Q' or 'q' flag.\n\nIt is also possible to communicate with cmdgfx_input by setting the title of the current window with the prefix 'input:' followed by one or more flags.\n");
		return 0;
	}

	h_stdin = GetInputHandle();
	h_stdout = GetOutputHandle();
		
	remove("inputflags.dat");

	if (argc > 1) {
		for (i=0; i < strlen(argv[1]); i++) {
			switch(argv[1][i]) {
				case 'k': bReadKey = 1; break;
				case 'K': bWaitKey = 1; break;
				case 'n': bSendNoEvent = 1; break;
				case 'u': bSendKeyUp = 1; break;
				case 'i': bIgnoreInputFlagsFile = 1; break;
				case 'x': bPadding = 1; break;
				case 'R': g_bReportSize = 1; GetDim(h_stdout); break;
				case 'I': bIgnoreTitleComm = 1; break;
				case 'A': bSendAll = 1; break;
				case 'M': case 'm' : {
					char wTime[64];
					bMouse = argv[1][i] == 'M'? 2: 1; j = 0; i++;
					while (argv[1][i] >= '0' && argv[1][i] <= '9') wTime[j++] = argv[1][i++];
					i--; wTime[j] = 0;
					if (j) mouseWait = atoi(wTime);
					break;
				}
				case 'W': case 'w': {
					char wTime[64];
					bWait = 1; if (argv[1][i] == 'W') bWait = 2; j = 0; i++;
					while (argv[1][i] >= '0' && argv[1][i] <= '9') wTime[j++] = argv[1][i++];
					i--; wTime[j] = 0;
					if (j) waitTime = atoi(wTime);
					break;
				}
				case 'z': bSleepingWait = 1; break;
			}
		}
	}

	GetConsoleMode(h_stdin, &oldfdwMode);
	fdwMode = oldfdwMode;
	if (bMouse) {
		fdwMode = fdwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT;
		fdwMode = fdwMode & ~ENABLE_QUICK_EDIT_MODE;
	}
	fdwMode = fdwMode | ENABLE_WINDOW_INPUT;
	
	SetConsoleMode(h_stdin, fdwMode);
	
	memset(g_padding, '-', 1028);
	
	do {
		retVal = 0;

		eventCount = 0;
		
		if (g_bReportSize) {
			int oldW = g_consoleWidth, oldH = g_consoleHeight;
			GetDim(h_stdout);
			//printf("%d %d\n", g_consoleWidth, g_consoleHeight);
			if (g_consoleWidth != oldW || g_consoleHeight != oldH) {
				g_bSizeChanged = 1;
				if (!bSendAll) {
					eventCount += forward_event(bSendNoEvent, bMouse, 99999, "KEY_EVENT 0 DOWN 0 VALUE 0  MOUSE_EVENT 0 X 0 Y 0 LEFT 0 RIGHT 0 LEFT_DOUBLE 0 RIGHT_DOUBLE 0 WHEEL 0", bPadding, 1);
				} else
					eventCount += forward_event(bSendNoEvent, bMouse, 99999, "", bPadding, 1);
			}
		}

		if (g_bSizeChanged == 0) {
			if (!bMouse && ((bReadKey && kbhit()) || bWaitKey)) {
				int k = getch();
				if (k == 224 || k == 0) k = 256 + getch();
				retVal = k;
				if (bSendAll)
					sprintf(sEventOutput, "KEY_EVENT 1 DOWN 1 VALUE %d", k);
				else
					sprintf(sEventOutput, "KEY_EVENT 1 DOWN 1 VALUE %d  MOUSE_EVENT 0 X 0 Y 0 LEFT 0 RIGHT 0 LEFT_DOUBLE 0 RIGHT_DOUBLE 0 WHEEL 0", k);
				eventCount += forward_event(bSendNoEvent, bMouse, k, sEventOutput, bPadding, !bSendAll);
				bWaitKey = 0;
			}

			if (bMouse) {
				DWORD cNumRead, iOut; 
				INPUT_RECORD irInBuf[128];
				int res, res2, key = -1, bKeyDown = 0, bWroteKey = 0;
				int bTimeOut = 0;
							
				if (mouseWait > -1) {
					res = WaitForSingleObject(h_stdin, mouseWait);
					if (res & WAIT_TIMEOUT) bTimeOut = 1;
				}

				if (!bSendAll) {
					strcpy(sMouseOutput, "MOUSE_EVENT 0 X 0 Y 0 LEFT 0 RIGHT 0 LEFT_DOUBLE 0 RIGHT_DOUBLE 0 WHEEL 0");
					sprintf(sKeyOutput, "KEY_EVENT 0 DOWN 0 VALUE 0");
				}

				res = -1;
				if (!bTimeOut) {
					ReadConsoleInput(h_stdin, irInBuf, 128, &cNumRead);
					for (i = 0; i < cNumRead; i++) {
						int bOk;

						switch(irInBuf[i].EventType) { 
						
						case WINDOW_BUFFER_SIZE_EVENT: // resize events are ONLY sent if the window is ENLARGED! From its original size.
							eventCount++;
							break;

						case MOUSE_EVENT:
							bOk = 1;
							if (bMouse == 1) bOk = MouseClicked(irInBuf[i].Event.MouseEvent);
							if (bOk) {
								res = MouseEventProc(irInBuf[i].Event.MouseEvent, sMouseOutput);
								if (bSendAll)
									eventCount += forward_event(bSendNoEvent, bMouse, res, sMouseOutput, bPadding, 0);
							}
							break;
						case KEY_EVENT:
							bKeyDown = irInBuf[i].Event.KeyEvent.bKeyDown;
							if (irInBuf[i].Event.KeyEvent.uChar.AsciiChar > 0)
								key = irInBuf[i].Event.KeyEvent.uChar.AsciiChar;
							else
								key = 256 + irInBuf[i].Event.KeyEvent.wVirtualScanCode; // works ok, as long as not pressing combos such as Shift-F1 etc. To get these combo values too, re-send the event and pick it up with getch below

							if (bSendAll) {
								sprintf(sEventOutput, "KEY_EVENT 1 DOWN %d VALUE %d", bKeyDown, key);
								eventCount += forward_event(bSendNoEvent, bMouse, 1, sEventOutput, bPadding, 0);
							} else {
								irInBuf[i].Event.KeyEvent.bKeyDown = 1; WriteConsoleInput(h_stdin, &irInBuf[i], 1, &iOut);
								irInBuf[i].Event.KeyEvent.bKeyDown = 0; WriteConsoleInput(h_stdin, &irInBuf[i], 1, &iOut);
								bWroteKey = 1;
							}

			//				printf("DWN:%d REP:%d %d %d %d %d key:%d CK:%ld\n", irInBuf[i].Event.KeyEvent.bKeyDown, irInBuf[i].Event.KeyEvent.wRepeatCount, irInBuf[i].Event.KeyEvent.wVirtualKeyCode, irInBuf[i].Event.KeyEvent.wVirtualScanCode, irInBuf[i].Event.KeyEvent.uChar.UnicodeChar, irInBuf[i].Event.KeyEvent.uChar.AsciiChar, key, irInBuf[i].Event.KeyEvent.dwControlKeyState);
							break;
						case FOCUS_EVENT:
						case MENU_EVENT:
							break;
						}
					}
					
					if (bWroteKey) {
						if (kbhit()) {
							key=getch();
							if (key == 224 || key == 0) key = 256 + getch();
							while(kbhit()) getch();
						}
						res2 = WaitForSingleObject(h_stdin, 1);
						if (!(res2 & WAIT_TIMEOUT))
							ReadConsoleInput(h_stdin, irInBuf, 128, &cNumRead);			

						if (bKeyDown || bSendKeyUp) {
							res = (res > 0? res : 0) | (key<<22);
							res = res | (bKeyDown<<21);

							sprintf(sKeyOutput, "KEY_EVENT 1 DOWN %d VALUE %d", bKeyDown, key);
						}
					}
				}
				
				if (res > -1 && !bSendAll) {
					sprintf(sEventOutput, "%s  %s", sKeyOutput, sMouseOutput);
					
					eventCount += forward_event(bSendNoEvent, bMouse, res, sEventOutput, bPadding, 1);
				}

				retVal = res;
			}
		}

		g_bSizeChanged = 0;
		
		process_waiting(bWait, waitTime, bSleepingWait);
		
		if (bServer) {

			pch = NULL;
			if (!bIgnoreTitleComm) {
				HWND consoleWindow = GetConsoleWindow();
				if (consoleWindow!= NULL) {
					GetWindowText(consoleWindow, sTempTitleBuffer, 1023);
					if (strstr(sTempTitleBuffer, "input:") == sTempTitleBuffer) {
						SetWindowText(consoleWindow, sTitleBuffer);
						pch = strtok(sTempTitleBuffer, " ");
					} else
						strcpy(sTitleBuffer, sTempTitleBuffer);
				}
			}
			
			if (pch == NULL) {
				FILE	*flushFile = NULL;
				if (!bIgnoreInputFlagsFile)
					flushFile = fopen("inputflags.dat", "r");
				if (flushFile) {
					char *ffres = fgets(sFlags, 128, flushFile);
					if (ffres)
						pch = strtok(sFlags, " ");
					
					fclose(flushFile);
					if (pch)
						remove("inputflags.dat");
				}
			}
			
			if (pch) {
				int neg = 0;
				for (i = 0; i < strlen(pch); i++) {
					
					neg = 0;
					if (pch[i] == '-') { neg = 1; i++; }
					
					switch(pch[i]) {
						case 'q': case 'Q': bServer = 0; break;
						case 'k': bReadKey = neg? 0 : 1; if (bReadKey) bMouse = 0; break;
						case 'K': bWaitKey = 1; break;
						case 'n': bSendNoEvent = neg? 0 : 1; break;
						case 'u': bSendKeyUp = neg? 0 : 1; break;
						case 'A': bSendAll = neg? 0 : 1; break;
						case 'I': bIgnoreTitleComm = neg? 0 : 1; break;
						case 'x': bPadding = neg? 0 : 1; break;
						case 'R': g_bReportSize = neg? 0 : 1; if (g_bReportSize) GetDim(h_stdout); break;
						case 'i': bIgnoreInputFlagsFile = neg? 0 : 1; break;
						case 'M': case 'm':{
							SetConsoleMode(h_stdin, oldfdwMode);
							if (neg)
								bMouse = 0;
							else {
								char wTime[64];
								bMouse = pch[i] == 'M'? 2 : 1; j = 0; i++;
								while (pch[i] >= '0' && pch[i] <= '9') wTime[j++] = pch[i++];
								i--; wTime[j] = 0;
								if (j) mouseWait = atoi(wTime);
								SetConsoleMode(h_stdin, fdwMode);
							}
							break;
						}
						case 'W': case 'w': {
							if (neg)
								bWait = 0;
							else {
								char wTime[64];
								bWait = 1; if (pch[i] == 'W') bWait = 2; j = 0; i++;
								while (pch[i] >= '0' && pch[i] <= '9') wTime[j++] = pch[i++];
								i--; wTime[j] = 0;
								if (j) waitTime = atoi(wTime);
							}
							break;
						}
						case 'z': bSleepingWait = neg? 0 : 1; break;				
					}
				}
			}
		}

		if (eventCount == 0) {
			eventCount += forward_event(bSendNoEvent, bMouse, retVal, "NO_EVENT 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0", bPadding, 0);
		}
		if (bSendAll) {
			eventCount += forward_event(1, 1, 1, "END_EVENTS 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0", bPadding, 0);
		}

		if (eventCount > 0)
			fflush(stdout);

	} while (bServer && (!feof(stdin)));

	SetConsoleMode(h_stdin, oldfdwMode);

	CloseHandle(h_stdin);
	CloseHandle(h_stdout);
	return retVal;
}
