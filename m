From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Sep 2006 08:30:21 +0000
Subject: Re:  CCID2: Tell DCCP to quickly check whether cwnd is available
Message-Id: <200609210930.21903@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Andrea,

I think what you are saying touches upon a very crucial issue and it is necessary
to get these architectural issues `right', i.e. generic and scalable enough, before
proceeding with other work (I'd be willing to put in effort). 

The general problem is that the horizon does not end with CCID 2 and CCID 3, rather:

 * CCID 4 is already in the pipeline (draft-ietf-dccp-tfrc-voip-05) to become RFC soon

 * there is a proposed faster-restart variant for CCID 3/4, so we will have CCID-3-`fr'
   and CCID-4-`fr' variants besides the `plain' standardised CCID 3/4

 * people at NEC have developed and implemented (Kame) yet another CCID-3 variant
   more specifically designed for VoIP applications

 * given the experimental state of using CCIDs in the Internet, it is more than likely
   that further CCIDs will soon evolve

Therefore the architectural concerns you are raising are of critical importance for the
overall success of the Linux DCCP framework. 

It is very much worth to focus on the architecture: a generic and well-designed, modular
interface between main DCCP module and CCID `plug-ins' will save *much* frustration and
having to revamp again in the future -- when more CCIDs are happily added to the landscape. 

I think it is wasting time to use temporary and non-scalable fixes and therefore would
like to expand on the following comments you made:

|  I don't think tx queueing immedeately "helps" solving this problem.  It's an
|  architectural change that I'm proposing.  In the current API, DCCP is the
|  "master" and asks the CCID if it can send.  The CCID either says yes, or says
|  "ask me again in X time".  I don't think this is great because some CCIDs don't
|  really have a concept of time.  In rate based protocols, perhaps there is a way
|  to say "OK I can send after X time" but in window based protocols it's "upon the
|  reception of the next ack".  OK one can give an esitmate of time [rtt/cwnd?] but
|  it still isn't great.
|  
|  By reversing the architecture, I think this problem is solved quite neatly.  In
|  this case, it is the CCID which drives DCCP.  The API would be: CCID tells DCCP
|  "hey, you can send" and DCCP sends happilly.  Not a poll & push model as before,
|  but rather a pull model from CCID's perspective.
<.....>
|  To summarize, the API would be as follows.  DCCP would implement:
|  void pull(int x);      /* Called by CCID, indicating that DCCP may send x packets */
|  
|  CCID would implement:
|  void notify(int true); /* if true, CCID will pull from DCCP, else not */

I have the following further discussion items regarding the CCID <=> main module interface:

 1/ TX Buffering: set size of TX ring buffer via socket option.
    There are interesting simulations which confirm the merit of having such and such 
    queue lenghts; the current code does not have a limit on the TX queue; and I am 
    referring to an effective circular-list implementation in [LK05].
    Maybe sendmsg() could just block if actual_qlen = max_qlen ??? The above callbacks
    seem a useful start here       =>  suggestions?

 2/ Keeping track of Maximum Packet Size (MPS, RFC 4340, sec. 14). 
    The main module needs to keep track of MPS which is influenced by CCMPS, the MPS
    determined by the CCID in use  =>  need a way to communicate CCMPS to main module

 3/ Fragmentation.
    MPS is also determined by path MTU (which appears to work). Currently, unlike UDP,
    EMSGSIZE is returned if buflen > MPS. The spec allows optional fragmentation for
    such cases where  CCMPS <=  buflen <= MPS. Again, the CCID needs to be set first 
    (sockopt), then the CCMPS be communicated to main module.

 4/ Interpretation/setting of the CCVal header field.

 5/ Feature negotiation: the feature negotiation code also depends on current CCID value.

API-wise, my understanding is that it all starts with setting the CCID socket option where
apparently CCID 2 acts as common denominator, since
 
   * new connections start with CCID 2 as default 
   * DCCP implementations "SHOULD implement at least CCID 2" [RFC 4340, sec. 10]

Hence if the CCID socket option is not set, fallback is CCID 2. Later, when feature negotiation
is over, the actual CCID in place can be queried via getsockopt - and at that time the CCID-in-place
is already communicating with the main module.

Lastly, a related issue is the use of the DCCP_SOCKOPT_PACKET_SIZE socket option: this
is a strange something, again is CCID-specific, and no current use for it can be seen 
- Ian McDonald has a patch which removes it. I am still wondering whether and if it has any 
use at all?

Comments, please.

Gerrit.


[LK05]       Lai, Junwen and Eddie Kohler. Efficiency and late data choice in
             a user-kernel interface for congestion-controlled datagrams. In
             Surendar Chandra and Nalini Venkatasubramanian, editors, Twelfth
             Annual Multimedia Computing and Networking (MMCN '05), San Jose,
             California, volume 5680 of Proceedings of the SPIE, pages
             136--142. 2005.

