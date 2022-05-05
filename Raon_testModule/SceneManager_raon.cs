using System.IO;
using UnityEngine;

public class SceneManager_raon : MonoBehaviour
{

    public UITexture targetTex;
    public UIInput input_filename, input_rgb_weight;
   // public UIInputfiled input_name;
    public UILabel label_rgb_weight;
    

    [HideInInspector] public Texture2D tex2d = null;
    
    byte[] fileData;

    [HideInInspector] public float r_w = 1, g_w = 1, b_w = 1;

    // Start is called before the first frame update
    void Start()
    {
        label_rgb_weight.text = "RGB Weight:: " + r_w.ToString() + ", " + g_w.ToString() + ", " + b_w.ToString();  
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void onClick_auto_set_rgb_weight(GameObject btnObj)
    {
        Weight_btn_manager weight_btn_manager =btnObj.GetComponent<Weight_btn_manager>();

        string strs= 
            weight_btn_manager.w_r.ToString() + ",  " + weight_btn_manager.w_g.ToString() + ",  " + weight_btn_manager.w_b.ToString();

        input_rgb_weight.value = strs;
        onClick_set_rgb_weight();
    }

    void onClick_set_rgb_weight()
    {
        try{

             StringUtilss sw = new StringUtilss();
            string [] strs =sw.get_divided_strs(input_rgb_weight.value.Trim(),",");
            r_w =  float.Parse(strs[0].Trim());
            g_w = float.Parse(strs[1].Trim());
            b_w = float.Parse(strs[2].Trim());

            label_rgb_weight.text = "Green Weight:: " + r_w.ToString() + ", " + g_w.ToString() + ", " + b_w.ToString();  
        }catch(System.Exception excep){
        }
    }

    void onClick_get_img(){

        print(input_filename.value);
        //print(input_name.string);

        string filePath = @"c:\raon\"+input_filename.value.Trim()+".JPG";
        print(filePath);

        FileInfo fi = new FileInfo(filePath);
        if (fi.Exists == false)
        {
            targetTex.mainTexture = new Texture2D(1,1);
            return;
        }



        byte[] fileData = File.ReadAllBytes(filePath);
        tex2d = new Texture2D(1024, 1024, TextureFormat.ARGB32, 3, true);
        tex2d.LoadImage(fileData); //..this will auto-resize the texture dimensions.

        targetTex.mainTexture = tex2d;


        // test
        /*
        print(tex2d.height);
        print(tex2d.width);


        Color[] colors = tex2d.GetPixels();

        print(colors[0]);*/
    }
}


























