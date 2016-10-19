using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;


/*
 * This is the MonoBehviour for controlling the special effects in the card shader.
 * It requires an Animator, MeshRenderer and a material with the card shader selected.
 */
[RequireComponent(typeof(Animator))]
public class CardAnimatorController : MonoBehaviour {

    Animator animator; // The animator for controller shader properties.

    // Define the strings for Triggers here to avoid typos in your code
    const string SparkleTrigger = "Sparkle";

    void Start()
    {
        animator = GetComponent<Animator>();
        StartCoroutine(SparkleCoroutine());
    }

    IEnumerator SparkleCoroutine()
    {
        // Run forever
        while(true) 
        {
            yield return new WaitForSeconds(Random.Range(2, 5)); // Wait for a random amount of time
            animator.SetTrigger(SparkleTrigger); // Tell the animator to start sparkling
        }
    }
}
