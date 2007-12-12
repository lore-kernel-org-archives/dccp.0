From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Dec 2007 16:42:31 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <20071212164231.GA2282@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| The scenario that I mostly use is limiting the bandwidth with a middlebox running TBF. However, all of the recent trees 
| except 2.6.20final_dccp (2.6.20 patched with Ian's modifications) that I have tested fail to achieve acceptable transfer rates. 
Thank you for the report, but the material as-is does not help us very much. What is missing is the link speed of the
ethernet cards that lead to the middlebox, and have you monitored the loss rate p? 
Using a TBF in this setting means slowing down the link speed by a factor of 10 .. 20, and unless you are using large
FIFOs in addition to the TBF, the loss rate will very soon reach high values.

Therefore, can you please clarify what you mean by "acceptable transfer rates": maybe the scenario is not supposed to
warrant any high transfer rates at all. Which would mean expecting something where not much can be expected - as said,
without more detailed knowledge about how p reacts, these figures don't tell us very much.

Didn't you have a web page with further information?

Furthermore, I don't think that this is a question of "Ian's patches" or "Gerrit's patches": between 2.6.20 and 2.6.25-rc4
there is a huge number of changes, among these the conversion to the ktime_t interface.


| Test setup is as follows, unless otherwise mentioned:
| 

| - Two Linux boxes are connected through another Linux box (middlebox) running netem. 
|   The boxes at the edge are identical machines with P4 2.4GHz and 512MB memory. Middlebox is a P4 2.6GHz with 512MB memory.
| - TBF is used to limit the bandwidth. TBF buffer is set as 10000 bytes and the limit is 30000 bytes.
| - 20ms constant delay is present in both sender->receiver and receiver->sender directions.
| - iperf in bytestream mode is used in these tests, and the streaming duration is set as 60 seconds.
| - DCCPv4 is used in the tests.
| 
| 
| Below are the results of the two different trees:
| 
| Kernel: 2.6.20final_dccp (2.6.20 davem tree with Ian's patches - except for the best_packet_next patch. The patches applied are not the latest ones which are updated at 2nd of December, but the ones before the latest.)
<snip>
| 
| While writing this mail, I noticed that Ian has updated his patch set for 2.6.20. I will use this set and repeat the tests this week, hopefully.i
| Moreover, I also tested Ian's patches for other trees (2.6.22 and 2.6.24) but the results were not as good as 2.6.20final_dccp results, if I remember correctly.
| I can go over them again, if necessary.
| 
Yes, please: the cleanest comparison would be to take a 2.6.24 tree, and compare the patch sets on the same basis. I almost expected that the
results are not as good as the 2.6.20final_dccp -- it is an almost sure indication that the difference is not due to the patches, and that
there are other factors at work. By carefully looking at these differences, we will be able to see clearer what is happening in the above.

Again thanks a lot for posting results, hope you will be back with
further information soon,

Gerrit
