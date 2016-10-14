using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;


/*
 * This is the MonoBehviour for controlling the special effects in the card shader.
 * It requires an Animator, MeshRenderer and a material with the card shader selected.
 */
[RequireComponent(typeof(Animator),typeof(MeshRenderer))]
public class CardController : MonoBehaviour {

    // How many seconds will it take for the card to dissapear.
    public float dissolveTime = 1;

    Animator animator; // The animator for controller shader properties.
    Material dissolveMaterial; // The material will do the dissolve.

    // Define the strings for Triggers and material properties here so
    //   you don't accidentally mis-spell them ni the code.
    const string SparkleTrigger = "Sparkle";
    const string DissolveAmountProperty = "_DissolveAmount";

    void Start()
    {
        animator = GetComponent<Animator>();

        // Get the material that will do the dissolve and make sure it has what we need.
        dissolveMaterial = GetComponent<MeshRenderer>().material;
        Assert.IsNotNull(dissolveMaterial, "Dissolve material required for dissolving");
        Assert.IsTrue(dissolveMaterial.HasProperty(DissolveAmountProperty), "Dissolve material doesn't have a dissolve amount property");

        // Start the sparkles up, they'll run for as long at the card is around
        StartCoroutine(SparkleCoroutine());
    }

    void Update () {
        // If the player presses space, we'll start the card dissolve
	    if( Input.GetKeyDown(KeyCode.Space))
        {
            StartCoroutine(DissolveCoroutine(dissolveTime));
        }
	}

    IEnumerator SparkleCoroutine()
    {
        // Run forever
        while(true) 
        {
            yield return new WaitForSeconds(Random.Range(5, 15)); // Wait for a random amount of time
            animator.SetTrigger(SparkleTrigger); // Tell the animator to start sparkling
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
            dissolveMaterial.SetFloat(DissolveAmountProperty, dissolveAmount);

            yield return null;
        }
    }
}
