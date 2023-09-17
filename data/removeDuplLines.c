#include <stdio.h>
#include <string.h>
#define MAXLEN 64000

int main(int argc, char **argv) {
	char indata[MAXLEN], indata2[MAXLEN];

	if (argc < 2) { puts("No file specified."); return 1; }
	FILE *fp = fopen(argv[1],"r");
	if (!fp) { puts("No such file."); return 1; }
	while(!feof(fp)) {
		fgets(indata,MAXLEN,fp);
		if (strcmp(indata, indata2)) printf("%s",indata);
		strcpy(indata2,indata);
	}
	fclose(fp);
	return 0;
}
