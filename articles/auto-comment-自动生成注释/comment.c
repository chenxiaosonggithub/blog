#include "stdio.h"
#include "string.h"
#include <time.h>

void create_func_comment(int argc, char *argv[])
{
    char front_str[1024];
    //char tmp[] = "static void funcname(int arga, char *argb, struct stru *ptr)adfa";
    //char tmp[] = "static void funcname(void)adfa";
    //char *str = tmp;
    char *str = argv[1];

    //左括号
    char *l_bracket_pos = strchr(str, '(');
    if(NULL == l_bracket_pos)
    {
        goto fail;
    }
    //printf("\n\rleft bracket:%s\n\r", l_bracket_pos);

    //前面部分（左括号前）
    memset(front_str, 0, sizeof(front_str));
    strncpy(front_str, str, strlen(str) - strlen(l_bracket_pos));
    //printf("\n\rfront str:%s\n\r", front_str);

    //函数名前的空格
    char *func_front_space_pos = strrchr(front_str, ' ');
    if(NULL == func_front_space_pos)
    {
        goto fail;
    }

    //打印 @fn 和 @brief
    printf("\n\r/** @fn : %s", func_front_space_pos + 1);
    printf("\n\r  * @brief : ");

    //右括号
    char *r_bracket_pos = strchr(str, ')');
    if(NULL == r_bracket_pos)
    {
        goto fail;
    }
    //printf("\n\rright bracket:%s\n\r", r_bracket_pos);

    //参数
    char *none_arg_pos = strstr(l_bracket_pos, "void");
    if(NULL != none_arg_pos)
    {
        printf("\n\r  * @param : None");
    }
    else
    {
        //参数前的空格
        char *arg_front_space_pos;
        //逗号
        char *comma_pos = strchr(l_bracket_pos, ',');
        while(NULL != comma_pos)
        {
            //前面部分（左括号到当前逗号）
            memset(front_str, 0, sizeof(front_str));
            strncpy(front_str, l_bracket_pos, strlen(l_bracket_pos) - strlen(comma_pos));
            //printf("\n\rfront str:%s\n\r", front_str);
            //参数前的空格
            arg_front_space_pos = strrchr(front_str, ' ');
            printf("\n\r  * @param %s : ", arg_front_space_pos + 1);
            //下一个逗号
            comma_pos = strchr(comma_pos + 1, ',');
        }
        //最后一个参数
        //前面部分（左括号到右括号）
        memset(front_str, 0, sizeof(front_str));
        strncpy(front_str, l_bracket_pos, strlen(l_bracket_pos) - strlen(r_bracket_pos));
        //printf("\n\rfront str:%s\n\r", front_str);
        //参数前的空格
        arg_front_space_pos = strrchr(front_str, ' ');
        printf("\n\r  * @param %s : ", arg_front_space_pos + 1);
    }

    //前面部分（左括号前）
    memset(front_str, 0, sizeof(front_str));
    strncpy(front_str, str, strlen(str) - strlen(l_bracket_pos));
    //printf("\n\rfront str:%s\n\r", front_str);
    //返回值
    char *return_pos = strstr(front_str, "void");
    printf("\n\r  * @return : ");
    if(NULL != return_pos)
    {
        printf("None");
    }
    printf("\n\r*/\n\r");
    return;
fail:
    printf("\n\r################wrong arg, try again\n\r");
}

void create_file_comment(int argc, char *argv[])
{
    char file_h_macro[64] = "";// 头文件宏定义
    time_t now = time(0);
    struct tm *ltm = localtime(&now);

    int is_header_file = 0;// 是否是头文件
    char *filename = argv[2];
    // 第一个参数必须是 "file"
    if(strcmp(argv[1], "file"))
    {
        goto fail;
    }
/**  @file : block_test.c
  *  @note : 
  *  @brief : 块设备测试
  *
  *  @author : 陈孝松
  *  @date : 2021.03.05 21:44
  *
  *  @note :
  *  @record :
  *       2021.03.05 21:44 created
  *       2021.03.17 18:45 增加多线程读写速度测试
  *
  *  @warning :
*/
    printf("/**  @file : %s", argv[2]);
    printf("\n\r");
    printf("  *  @note : ");
    printf("\n\r");
    printf("  *  @brief : ");
    printf("\n\r");
    printf("  *");
    printf("\n\r");
    printf("  *  @author : 陈孝松");
    printf("\n\r");
    printf("  *  @date : %d.%02d.%02d %02d:%02d", 1900 + ltm->tm_year, 1+ltm->tm_mon, ltm->tm_mday, ltm->tm_hour, ltm->tm_min);
    printf("\n\r");
    printf("  *");
    printf("\n\r");
    printf("  *  @note : ");
    printf("\n\r");
    printf("  *  @record : ");
    printf("\n\r");
    printf("  *       %d.%02d.%02d %02d:%02d created", 1900 + ltm->tm_year, 1+ltm->tm_mon, ltm->tm_mday, ltm->tm_hour, ltm->tm_min);
    printf("\n\r");
    printf("  *");
    printf("\n\r");
    printf("  *  @warning : ");
    printf("\n\r");
    printf("*/");
    // 头文件
    if('h' == filename[strlen(filename)-1] && '.' == filename[strlen(filename)-2])
    {
        char tmp = 0;
        sprintf(file_h_macro, "__");
        for(int i = 0; i < strlen(filename); i++)
        {
            tmp = filename[i];
            if('.' == filename[i])
            {
                tmp = '_';
            }
            // 转大写字母
            else if(filename[i] >= 'a' && filename[i] <= 'z')
            {
                tmp = filename[i] - ('a' - 'A');
            }
            sprintf(file_h_macro, "%s%c", file_h_macro, tmp);
        }
        sprintf(file_h_macro, "%s__", file_h_macro);

        printf("\n\r");
        printf("\n\r");
        printf("#ifndef %s", file_h_macro);
        printf("\n\r");
        printf("#define %s", file_h_macro);
        printf("\n\r");
        printf("\n\r");
        printf("#endif");
    }
    printf("\n\r");
    return;
fail:
    printf("\n\r################wrong arg, try again\n\r");
}

int main(int argc, char *argv[])
{
    if(2 == argc)
    {
        create_func_comment(argc, argv);
    }
    else if(3 == argc)
    {
        create_file_comment(argc, argv);
    }
    return 0;
}
