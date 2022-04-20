using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Lab_manager 
{
   
    double x, y, z;

    public Lab rgb2lab(float var_R, float var_G, float var_B)
    {

        float[] arr = new float[3];
        float B = gGamma(var_B);
        float G = gGamma(var_G);
        float R = gGamma(var_R);
        float X = 0.412453f * R + 0.357580f * G + 0.180423f * B;
        float Y = 0.212671f * R + 0.715160f * G + 0.072169f * B;
        float Z = 0.019334f * R + 0.119193f * G + 0.950227f * B;

        X /= 0.95047f;
        Y /= 1.0f;
        Z /= 1.08883f;

        float FX = X > 0.008856f ? Mathf.Pow(X, 1.0f / 3.0f) : (7.787f * X + 0.137931f);
        float FY = Y > 0.008856f ? Mathf.Pow(Y, 1.0f / 3.0f) : (7.787f * Y + 0.137931f);
        float FZ = Z > 0.008856f ? Mathf.Pow(Z, 1.0f / 3.0f) : (7.787f * Z + 0.137931f);
        float l = Y > 0.008856f ? (116.0f * FY - 16.0f) : (903.3f * Y);
        float a = 500f * (FX - FY);
        float b = 200f * (FY - FZ);

        Lab lab = new Lab();
        lab.l = l;
        lab.b = b;
        lab.a = a;

        return lab;
    }

    float gGamma(float x)
    {
        return x > 0.04045f ? Mathf.Pow((x + 0.055f) / 1.055f, 2.4f) : x / 12.92f;
    }

}
