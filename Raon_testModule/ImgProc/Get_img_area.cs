using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class Get_img_area : MonoBehaviour
{
    public SceneManager_raon sceneManager;
    public Rec_controller rec_controller;

    public UITexture tex_red_area, tex_green_area;
    public UILabel label_rgb_red_area, label_rgb_green_area;

    public UILabel label_diff, label_vv, label_diff_realLab;

    Color av_color_red_area = new Color(0, 0, 0, 0), av_color_green_area = new Color(0, 0, 0, 0);
    Texture2D tex2d_red_area = null, tex2d_green_area = null;

    Lab av_lab_red_area, av_lab_green_area;

    Lab_manager lm = new Lab_manager();

    void onClick_get_red()
    {
        GameObject target_rec_obj = rec_controller.rec_red;
        ArrayList resultList = get_target_area_img(target_rec_obj);

        av_color_red_area  = (Color)(resultList[0]);
        av_lab_red_area = new Lab_manager().rgb2lab(av_color_red_area.r, av_color_red_area.g, av_color_red_area.b);
        
        tex_red_area.mainTexture = tex2d_red_area =(Texture2D)(resultList[1]);

        string txt_to_show = av_color_red_area.ToString() 
            + "\n" + color_to_RGBstr(av_color_red_area)
            +"\n" + color_to_lab(av_color_red_area);
        label_rgb_red_area.text = txt_to_show;
    }


    void onClick_get_green()
    {
        GameObject target_rec_obj = rec_controller.rec_green;
        ArrayList resultList = get_target_area_img(target_rec_obj);

        av_color_green_area = (Color)(resultList[0]);
        av_color_green_area.r = av_color_green_area.r * sceneManager.r_w;
        av_color_green_area.g = av_color_green_area.g * sceneManager.g_w;
        av_color_green_area.b = av_color_green_area.b * sceneManager.b_w;

        if (av_color_green_area.r > 1) av_color_green_area.r = 1;
        if (av_color_green_area.g > 1) av_color_green_area.g = 1;
        if (av_color_green_area.b > 1) av_color_green_area.b = 1;

        av_lab_green_area = new Lab_manager().rgb2lab(av_color_green_area.r, av_color_green_area.g, av_color_green_area.b);

        tex_green_area.mainTexture = tex2d_green_area =(Texture2D)(resultList[1]);

        string txt_to_show = av_color_green_area.ToString() 
            + "\n" + color_to_RGBstr(av_color_green_area)
            + "\n" + color_to_lab(av_color_green_area);
        label_rgb_green_area.text = txt_to_show;

    }

    #region color changes -----------------------------------------
    string color_to_RGBstr(Color incolor)
    {
        string r = Mathf.Abs(incolor.r * 255).ToString();
        string g = Mathf.Abs(incolor.g * 255).ToString();
        string b = Mathf.Abs(incolor.b * 255).ToString();

        string strs = r + " / " + g + " / " + b;
        return strs;
    }

    string color_to_lab(Color incolor)
    {
        Lab lab = lm.rgb2lab(incolor.r, incolor.g, incolor.b);

        string strs = lab.l.ToString() + " / " + lab.a.ToString() + " / " + lab.b.ToString();
        return strs;
    }

    #endregion ---------------------------------------------------------------


    ArrayList get_target_area_img(GameObject target_rec_obj)
    {
        Texture2D origin_tex2d = sceneManager.tex2d;

        int ori_img_height = origin_tex2d.height;
        int ori_img_width = origin_tex2d.width;

        Vector3 pos = target_rec_obj.transform.localPosition;
        int x =(int)(pos.x + 240);
        int y = (int)(pos.y - 350);
        y = Mathf.Abs(y);

        print(x);
        print(y);

        // convert ui img to real img
        
        // ui img : 480 700 , area: 16*16
        // real img: origin_tex2d

        // 오리지날 이미지상 리얼 좌표 구하기
        int real_x = (int)(ori_img_width / 480.0 * x);
        int real_y = (int)(ori_img_height / 700.0 * y);

        print(real_x);
        print(real_y);

        // 탐색 영역 오리지날 이미지 상에서 크기 구하기
        int search_x = (int)(ori_img_width / 480.0 * 16);
        int search_y = (int)(ori_img_height / 700.0 * 16);

        print(search_x);
        print(search_y);

        //Color [] origin_colors = origin_tex2d.GetPixels();


        int newH = search_y;
        int newW = search_x;

        Texture2D newTex = new Texture2D(newW, newH, TextureFormat.ARGB32, 3,true);
        int mipCount = Mathf.Min(3, newTex.mipmapCount);


        float r = 0;
        float g = 0;
        float b = 0;
        int count = 0;

        for (int i = real_y; i < real_y + search_y; i++)
        {
            for (int j = real_x; j < real_x + search_y; j++)
            {
                Color thisColor = origin_tex2d.GetPixel(j, i);
                newTex.SetPixel(j, i, thisColor);

                r +=thisColor.r;
                g += thisColor.g;
                b += thisColor.b;

                print(thisColor);

                count++;
            }
        }

        Color av_colors=  new Color(r/count, g/count, b/count,1);

        newTex.Apply();

        byte[] bytes = newTex.EncodeToPNG();
        File.WriteAllBytes(@"c:\raon\_capture.png", bytes);

        ArrayList newResult_list = new ArrayList();
        newResult_list.Add(av_colors);
        newResult_list.Add(newTex);

        return newResult_list;
    }

    void Update()
    {
        try
        {
            if (av_color_red_area == new Color(0, 0, 0, 0) || av_color_green_area == new Color(0, 0, 0, 0)) return;

            //print(av_color_red_area);

            float r_gap = av_color_red_area.r - av_color_green_area.r;
            float g_gap = av_color_red_area.g - av_color_green_area.g;
            float b_gap = av_color_red_area.b - av_color_green_area.b;

            float sums = r_gap * r_gap + g_gap * g_gap + b_gap * b_gap;
            float diff = Mathf.Sqrt(sums);

            string str1 =  "RGB Diff: " + diff.ToString();
            label_diff.text = str1;

          //  print(av_lab_red_area.a);

            float lab_a_gap = av_lab_red_area.a - av_lab_green_area.a;
            float lab_b_gap = av_lab_red_area.b - av_lab_green_area.b;
            float lab_l_gap = av_lab_red_area.l - av_lab_green_area.l;

            sums = lab_a_gap * lab_a_gap + lab_b_gap * lab_b_gap;
            diff = Mathf.Sqrt(sums);

            string str2 = "     Lab Diff: " + (diff/100).ToString();
            label_diff.text = str1+str2;

            sums = lab_a_gap * lab_a_gap + lab_b_gap * lab_b_gap + lab_l_gap *lab_l_gap ;
            diff = Mathf.Sqrt(sums);
            str2 = "Real Lab Diff: " + (diff / 100).ToString();
            label_diff_realLab.text = str2;
        }
        catch (System.Exception ee)
        {
        }
       
    }

    void onClick_get_vv()
    {
        if (tex2d_red_area == null) return;
        onClick_get_red();
        int height = tex2d_red_area.height;
        int width = tex2d_red_area.width;

        Texture2D vv_tex2d = new Texture2D(width, height);

        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {

                Color center_color = new Color(0,0,0,0);
                float rs=0, gs=0, bs=0;
                int count = 0;

                for (int p = i - 1; p <= i + 1; p++)
                {
                    for (int t = j - 2; t <= j + 2; t++)
                    {
                        if (p < 0 || t < 0 || p >= height || t >= width)
                        {
                            continue;
                        }

                        Color this_color = tex2d_red_area.GetPixel(t, p);


                        if (p == i && j == t)
                        {
                            center_color = this_color;
                            continue;
                        }

                        rs += this_color.r;
                        gs += this_color.g;
                        bs += this_color.b;

                        count++;
                    }
                }

                float center_r = center_color.r * count;
                float center_g = center_color.g * count;
                float center_b = center_color.b * count;

                float gap_r = Mathf.Abs(center_r - rs);
                float gap_g = Mathf.Abs(center_g - gs);
                float gap_b = Mathf.Abs(center_b - bs);

                if (gap_r > 1) gap_r = 1;
                if (gap_g > 1) gap_g = 1;
                if (gap_b > 1) gap_b = 1;

                Color new_color = new Color(gap_r, gap_g, gap_b, 1);

                vv_tex2d.SetPixel(j, i, new_color);
            }
        }

        vv_tex2d.Apply();
        tex_red_area.mainTexture = vv_tex2d;

        // get vv value
        double sum = 0;
        int vv_count = 0;

        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {
                Color this_color =  vv_tex2d.GetPixel(j, i);

                float r = this_color.r;
                float g = this_color.g;
                float b = this_color.b;

                sum += r + g + b;
                vv_count++;
            }
        }


        double vv = sum / vv_count;
        label_vv.text = "vv: " + vv.ToString();
    }
}






































