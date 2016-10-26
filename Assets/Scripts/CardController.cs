using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;


/*
 * This is the MonoBehviour for controlling the special effects in the card shader.
 * It requires an Animator, MeshRenderer and a material with the card shader selected.
 */
[RequireComponent(typeof(MeshRenderer))]
public class CardController : MonoBehaviour {

    // How many seconds will it take for the card to dissapear.
    public float dissolveTime = 1;

    Material dissolveMaterial; // The material will do the dissolve.

    void Start()
    {
        // Get the material that will do the dissolve and make sure it has what we need.
        dissolveMaterial = GetComponent<MeshRenderer>().material;
        Assert.IsNotNull(dissolveMaterial, "Dissolve material required for dissolving");
        Assert.IsTrue(dissolveMaterial.HasProperty("_DissolveAmount"), "Dissolve material doesn't have a dissolve amount property");
    }

    void Update () {
        // If the player presses space, we'll start the card dissolve
	    if( Input.GetKeyDown(KeyCode.Space))
        {
            StartCoroutine(DissolveCoroutine(dissolveTime));
        }
	}

    IEnumerator DissolveCoroutine(float dissolveTime)
    {
        float startTime = Time.time;
        float endTime = startTime + dissolveTime;

        while(endTime > Time.time)
        {
            // Scale the elapsed time to be between 0 and 1
            float elapsedTime = Time.time - startTime;
            float dissolveAmount = elapsedTime / dissolveTime;

            // Set the dissolve property in the material
            dissolveMaterial.SetFloat("_DissolveAmount", dissolveAmount);

            yield return null;
        }
    }
}
