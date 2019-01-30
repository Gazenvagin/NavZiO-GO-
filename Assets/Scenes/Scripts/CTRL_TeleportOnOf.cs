using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EasyInputVR.StandardControllers;

public class CTRL_TeleportOnOf : MonoBehaviour
{
    public StandardTeleportReceiver tlpOnOf;
    public GameObject grndPlnt;

    public static GameObject groundPlant;
    public static StandardTeleportReceiver teleportOnOf;
    public static Collider groundTriggerPlant;

    private Collider grndTrgPlnt;


    private void Awake()
    {

        grndTrgPlnt = grndPlnt.GetComponent<Collider>();

        groundPlant = grndPlnt;
        teleportOnOf = tlpOnOf;
        groundTriggerPlant = grndTrgPlnt;
         
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }
}
