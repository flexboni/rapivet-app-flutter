using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weight_btn_manager : MonoBehaviour
{

    public float w_r, w_g, w_b;

    // Start is called before the first frame update
    void Start()
    {
        this.gameObject.transform.Find("Label").gameObject.GetComponent<UILabel>().text =
            w_r.ToString() + "  " + w_g.ToString() + "  " + w_b.ToString();
    }

}
