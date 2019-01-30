using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CTRLtriggersPoints : MonoBehaviour
{
    public static GameObject[] point;

    public GameObject[] pointsGroundPlant;

    private void Awake()
    {
        //point = GameObject.FindGameObjectsWithTag("pointTrigg");
    }

    void Start()

    {
        point = pointsGroundPlant;
        //pointsGroundPlant = point;
    }


    void Update()
    {
        
    }
}
