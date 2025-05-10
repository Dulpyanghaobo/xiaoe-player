//
//  AntPlayerH-Bridging-Header.h
//  AntPlayerH
//
//  Created by i564407 on 8/13/24.
//

#ifndef AntPlayerH_Bridging_Header_h
#define AntPlayerH_Bridging_Header_h
#import "ZSSRichTextEditor.h"
#import "ZSSBarButtonItem.h"


int get_attribute(const char *filepath, const char *attribute, char *value, int size);
int set_attribute(const char *filepath, const char *attribute, const char *value, int size);
char *get_file_md5(const char *filename, char md5str[32]);



#endif /* AntPlayerH_Bridging_Header_h */
