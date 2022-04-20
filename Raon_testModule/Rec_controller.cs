using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rec_controller : MonoBehaviour
{
    public enum CONTROL_MODE { RED, GREEN };

    GameObject target_control_obj;

    public UITexture uiTex_target;

    public GameObject rec_red;
    public GameObject rec_green;

    public UIToggle toggle_micro_movemnt;

    [HideInInspector] public CONTROL_MODE controll_mode;

    Unity_gameObj_manager ugm = new Unity_gameObj_manager();

    void Start()
    {
        controll_mode = CONTROL_MODE.RED;
        target_control_obj = rec_red;
    }

    void onClick_select_red_obj()
    {
        controll_mode = CONTROL_MODE.RED;
        target_control_obj = rec_red;
        print(target_control_obj);
    }

    void onClick_select_green_obj()
    {
        controll_mode = CONTROL_MODE.GREEN;
        target_control_obj = rec_green;
        print(target_control_obj);
    }

    // Update is called once per frame
    void Update()
    {

        float  weight = 1;

        if (Input.GetKey(KeyCode.LeftShift)) weight = 10;
        if (Input.GetKey(KeyCode.LeftControl)) weight = 30;

        if (toggle_micro_movemnt.value) weight = 0.05f;

        if (Input.GetKey(KeyCode.DownArrow))
        {
            float target_y = target_control_obj.transform.localPosition.y - 1* weight;
            ugm.set_local_y(target_control_obj, target_y);
        }

        if (Input.GetKey(KeyCode.UpArrow))
        {
            float target_y = target_control_obj.transform.localPosition.y + 1 * weight;
            ugm.set_local_y(target_control_obj, target_y);
        }

        if (Input.GetKey(KeyCode.LeftArrow))
        {
            float target_x = target_control_obj.transform.localPosition.x - 1 * weight;
            ugm.set_local_x(target_control_obj, target_x);
        }

        if (Input.GetKey(KeyCode.RightArrow))
        {
            float target_x = target_control_obj.transform.localPosition.x + 1 * weight;
            ugm.set_local_x(target_control_obj, target_x);
        }

        if (target_control_obj.transform.localPosition.y < -334)
        {
            ugm.set_local_y(target_control_obj, -334);
        }

        if (target_control_obj.transform.localPosition.y > 350)
        {
            ugm.set_local_y(target_control_obj, 350);
        }

        if (target_control_obj.transform.localPosition.x >224)
        {
            ugm.set_local_x(target_control_obj, 224);
        }

        if (target_control_obj.transform.localPosition.x < -240)
        {
            ugm.set_local_x(target_control_obj, -240);
        }
    }
}
