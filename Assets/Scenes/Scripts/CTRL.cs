﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SWS;
using UnityEngine.EventSystems;
using EasyInputVR.Misc;
using EasyInputVR.StandardControllers;
using UnityEngine.UI;

public class CTRL : MonoBehaviour
{
    public splineMove splineMgr;
    public PathManager[] pathMgr;
    public int pointMgr = 5;
    public float speedMgr = 10f;

    [Space(10)]

    public GameObject mMenu;
    public GameObject lgs;
    public static GameObject mainMenu;
    public static GameObject logos;

    [Space(10)]

    public EasyInputModule easyMod;
    public float farUI_Cam = 3000f;
    private Camera UI_Camera;
    private pointerSwitch laserCapsul;
    private StandardLaserPointer standartLaser;

    [Space(10)]

    public GameObject capsul;
    public Transform respawnSky;
    private Rigidbody rgBody;
    private AudioSource soundPlayer;
    private GameObject[] points;


    /// End variables------------------------------------------------------------------------------------------------------------ 
    ///

    private void OnEnable()
    {
        mainMenu = mMenu;
        logos = lgs;
    }

    #region Start()

    void Start()
    {
        //CTRL_TeleportOnOf.teleportOnOf.enabled = false;
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = false;

        CTRL_FadeCam.fadeCam.delay = 0f;
        CTRL_FadeCam.fadeCam.duration = 2f;
        CTRL_FadeCam.fadeCam.DOPlayById("fadeCam");

        RenderSettings.skybox = CTRL_SkyMat.mSkyGround;

        mainMenu.SetActive(false);
        logos.SetActive(false);

        laserCapsul = capsul.GetComponent<pointerSwitch>();
        standartLaser = laserCapsul.laserPointer.GetComponent<StandardLaserPointer>();
        splineMgr = capsul.GetComponent<splineMove>();
        rgBody = capsul.GetComponent<Rigidbody>();
        soundPlayer = capsul.GetComponent<AudioSource>();

        UI_Camera = easyMod.GetComponent<EasyInputModule>().UICamera;
        UI_Camera.depth = -1.1f;
        UI_Camera.farClipPlane = farUI_Cam;

        laserCapsul.laserPointer.SetActive(true);
        standartLaser.laserDistance = 150f;
        standartLaser.reticleDistance = 200f;

        rgBody.useGravity = false;

        points = CTRLtriggersPoints.point;
        
        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
        }
    }

    #endregion

    void Update()
    {
        
    }

    public void StartTour()
    {
        RenderSettings.skybox = CTRL_SkyMat.mSkyFly;

        //CTRL_TeleportOnOf.teleportOnOf.enabled = false;
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = false;

        CTRL_FadeCam.fadeCam.delay = 0.15f;
        CTRL_FadeCam.fadeCam.duration = 2.1f;
        CTRL_FadeCam.fadeCam.DORestartById("fadeCam");
        CTRL_FadeCam.fadeCam.DOPlayById("fadeCam");

        mainMenu.SetActive(true);
        logos.SetActive(true);

        standartLaser.laserDistance = 2501f;
        standartLaser.reticleDistance = 3001f;

        capsul.transform.position = respawnSky.position;
        capsul.transform.rotation = respawnSky.rotation;
    }

    public void StartButton1()
    {
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 0;

        splineMgr.pathContainer = pathMgr[0];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[0].SetActive(true);
        }

        rgBody.isKinematic = true;
        rgBody.useGravity = false;


        mainMenu.SetActive(false);
        logos.SetActive(false);
    }

    public void StartButton2()
    {
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 0;

        splineMgr.pathContainer = pathMgr[1];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[1].SetActive(true);
        }

        rgBody.isKinematic = true;
        rgBody.useGravity = false;

        mainMenu.SetActive(false);
        logos.SetActive(false);
    }

    public void StartButton3()
    {
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 0;

        splineMgr.pathContainer = pathMgr[2];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[2].SetActive(true);
        }

        rgBody.isKinematic = true;
        rgBody.useGravity = false;

        mainMenu.SetActive(false);
        logos.SetActive(false);
    }

    public void StartButton4()
    {
        //CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        soundPlayer.Play();

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 1;

        rgBody.isKinematic = false;
        rgBody.useGravity = true;

        splineMgr.pathContainer = pathMgr[3];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.OutBack;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[3].SetActive(true);
        }

        mainMenu.SetActive(false);
        logos.SetActive(false);

        StartCoroutine(Huyak());
    }

    #region Coroutinae butt4

    IEnumerator Huyak ()
    {

        laserCapsul.laserPointer.SetActive(false);

        yield return new WaitForSeconds(5f);

        RenderSettings.skybox = CTRL_SkyMat.mSkyFly;

        //CTRL_TeleportOnOf.teleportOnOf.enabled = false;
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = false;

        CTRL_FadeCam.fadeCam.delay = 0.15f;
        CTRL_FadeCam.fadeCam.duration = 2.1f;
        CTRL_FadeCam.fadeCam.DOPlayById("fadeCam");

        mainMenu.SetActive(true);
        logos.SetActive(true);

        rgBody.isKinematic = true;

        laserCapsul.laserPointer.SetActive(true);
        standartLaser.laserDistance = 2501f;
        standartLaser.reticleDistance = 3001f;

        capsul.transform.position = respawnSky.position;
        capsul.transform.rotation = respawnSky.rotation;

        yield break;
    }

    #endregion

    public void StartButton5()
    {
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 0;

        splineMgr.pathContainer = pathMgr[4];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[4].SetActive(true);
        }

        rgBody.isKinematic = true;
        rgBody.useGravity = false;

        mainMenu.SetActive(false);
        logos.SetActive(false);
    }

    public void StartButton6()
    {
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 0;

        splineMgr.pathContainer = pathMgr[5];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[5].SetActive(true);
        }

        rgBody.isKinematic = true;
        rgBody.useGravity = false;

        mainMenu.SetActive(false);
        logos.SetActive(false);
    }

    /// <summary>
    /// Point - 8
    /// </summary>

    public void StartButton8()
    {
        CTRL_TeleportOnOf.groundTriggerPlant.enabled = true;

        laserCapsul.laserPointer.SetActive(false);

        pointMgr = 0;

        splineMgr.pathContainer = pathMgr[7];
        splineMgr.startPoint = pointMgr;
        splineMgr.onStart = true;
        splineMgr.moveToPath = true;
        splineMgr.reverse = true;
        splineMgr.speed = speedMgr;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        splineMgr.StartMove();

        for (int i = 0; i < points.Length; i++)
        {
            points[i].SetActive(false);
            points[7].SetActive(true);
        }

        rgBody.isKinematic = true;
        rgBody.useGravity = false;

        mainMenu.SetActive(false);
        logos.SetActive(false);
    }

}

/*
 splineMove spM = vini.AddComponent<splineMove>();
        spM.enabled = true;
        spM = vini.GetComponent<splineMove>();
        spM.pathContainer = ptM;
        spM.startPoint = m;
        spM.onStart = true;                            
        spM.moveToPath = true;
        spM.speed = 1.5f;
        spM.loopType = splineMove.LoopType.loop;
        splineMgr.easeType = DG.Tweening.Ease.INTERNAL_Zero;
        spM.closeLoop = true;
        spM.StartMove();
 */
