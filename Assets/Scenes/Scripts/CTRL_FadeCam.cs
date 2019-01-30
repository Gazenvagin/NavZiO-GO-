using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CTRL_FadeCam : MonoBehaviour
{

    public static DOTweenAnimation fadeCam;

    private void Awake()
    {
        fadeCam = GetComponent<DOTweenAnimation>();
    }

    void Start()
    {
        
    }


    void Update()
    {
        
    }
}
