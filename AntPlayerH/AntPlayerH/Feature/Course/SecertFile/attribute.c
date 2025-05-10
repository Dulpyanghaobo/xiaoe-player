#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int get_attribute(const char *filepath, const char *attribute, char *value, int size)
{
	static char c1 = (char)'0x42';
	static char c2 = (char)'0x2a';
	FILE *f = fopen(filepath, "rb");
	if (!f)
	{
		return -1;
	}
	fseek(f, -2, SEEK_END);
	char id[2] = {0};
	fread(id, 2, 1, f);

	uint16_t len = 0;
	uint32_t total = 0;

	if (id[0] != c1 || id[1] != c2)
	{
		return -1;
	}

	fseek(f, -6, SEEK_END);
	fread(&total, 4, 1, f);
	long off = total + 6;
	fseek(f, -off, SEEK_END);

	int ret = -1;
	while (!feof(f))
	{
		char attr[128] = {0};
		if (1 != fread(&len, 2, 1, f))
		{
			break;
		}
		if (1 != fread(attr, len, 1, f))
		{
			break;
		}
		if (1 != fread(&len, 2, 1, f))
		{
			break;
		}
		printf("%s %s\n", attr, attribute);
		if (0 == strcmp(attr, attribute))
		{
			fread(value, len, 1, f);
			ret = 0;
			continue;
		}
		fseek(f, len, SEEK_CUR);
	}

	return ret;
}

int set_attribute(const char *filepath, const char *attribute, const char *value, int size)
{
	static char c1 = (char)'0x42';
	static char c2 = (char)'0x2a';
	FILE *f = fopen(filepath, "rb+");
	if (!f)
	{
		return -1;
	}
	fseek(f, -2, SEEK_END);
	char id[2] = {0};
	fread(id, 2, 1, f);

	uint16_t len = 0;
	uint32_t total = 0;

	if (id[0] == c1 && id[1] == c2)
	{
		fseek(f, -6, SEEK_END);
		fread(&total, 4, 1, f);
		fseek(f, -6, SEEK_END);
	}

	len = strlen(attribute);
	fwrite(&len, 2, 1, f);
	fwrite(attribute, len, 1, f);
	total += len + 2;
	len = (uint16_t)size;
	fwrite(&len, 2, 1, f);
	fwrite(value, len, 1, f);
	total += len + 2;
	fwrite(&total, 4, 1, f);
	id[0] = c1;
	id[1] = c2;
	fwrite(id, 2, 1, f);
	fclose(f);

	return 0;
}
//
//int main(int argc, char *argv[])
//{
//	// set_attribute(argv[1], "guojiai1", "zhongguo", 8);
//	// set_attribute(argv[1], "guojia", "beijing", 7);
//	// set_attribute(argv[1], "name", "zhangsan", 8);
//	set_attribute(argv[1], "name", "lisi", 4);
//	set_attribute(argv[1], "name", "中国", 7);
//	set_attribute(argv[1], "sex", "男", 7);
//
//	// set_attribute(argv[1], "guojia", "beijing", 7);
//
//
//	char value1[128] = {0};
//	get_attribute(argv[1], argv[2], value1, 128);
//	printf("name: %s\n", value1);
//
//	char value2[128] = {0};
//	get_attribute(argv[1], "sex", value2, 128);
//	printf("sex: %s\n", value2);
//	return 0;
//}
