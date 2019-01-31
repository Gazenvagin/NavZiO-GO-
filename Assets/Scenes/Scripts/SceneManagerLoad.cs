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

    void Start()
    {
        load.fillAmount = 0f;
        LoadScene();
    }

    void Update()
    {
        
    }

    public void LoadScene()
    {
        StartCoroutine( LoadAsync() );
    }

    IEnumerator LoadAsync()
    {
        AsyncOperation operation = SceneManager.LoadSceneAsync(sceneID);

        while (!operation.isDone)
        {
            float progress = Mathf.Clamp01(operation.progress / .9f);
            load.fillAmount = progress;

            procent.text = string.Format("{0:0}%", progress * 100);

            yield return null;
            Debug.Log("tamtam");
        }

        //loader.SetActive(false);
        Debug.Log("adios");

        //yield break;
    }
}
