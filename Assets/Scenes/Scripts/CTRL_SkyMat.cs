using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CTRL_SkyMat : MonoBehaviour
{

    public Material matSkyBox;
    public Material matSkyGround;
    public Texture texSky;
    public Texture texGround;

    public static Material mSkyFly;
    public static Material mSkyGround;
    public static Texture tSkyFly;
    public static Texture tSkyGround;

    private void OnEnable()
    {
        mSkyFly = matSkyBox;
        mSkyGround = matSkyGround;
        tSkyFly = texSky;
        tSkyGround = texGround;
    }

    void Start()
    {

    }

    void Update()
    {
        
    }
}
