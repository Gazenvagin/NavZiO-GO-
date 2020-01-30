using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class SceneManagerLoad : MonoBehaviour
{
    public GameObject loader;
    public Image load;    
    public Text procent;

    public int sceneID;

    void Awake()
    {
        StartCoroutine(PauseLoad());
    }

    void Start()
    {
        load.fillAmount = 0f;
        //LoadScene();
    }

    void Update()
    {
        
    }

    IEnumerator PauseLoad()
    {
        yield return new WaitForSeconds(5f);

        StartCoroutine(AsyncLoad());
    }

    IEnumerator AsyncLoad()
    {
        StopCoroutine(PauseLoad());

        AsyncOperation operation = SceneManager.LoadSceneAsync(sceneID);

        while (!operation.isDone)
        {
            float progress = Mathf.Clamp01(operation.progress / 0.9f);

            load.fillAmount = progress;

            //load.fillAmount = operation.progress;

            procent.text = string.Format("{0:0}%", progress * 100);            

            yield return null;                       
        }
        Debug.Log("adios"); 
    }
}
