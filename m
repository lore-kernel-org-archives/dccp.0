From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 03 Oct 2006 10:14:48 +0000
Subject: Re: PACKET_SIZE option and congestion control on variable-length packets
Message-Id: <200610031114.48986@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200610021108.57676@strip-the-willow>
In-Reply-To: <200610021108.57676@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > Strategy
|  > ----------
|  > 1/ Remove the PACKET_SIZE socket options as they don't help with the problem;
|  >     I have therefore updated Ian's patch to be used standalone [attached].
|  
|  NAK this patch. At present it just sets s to be 256 bytes where the
|  spec says to use the MSS. My patch is not perfect but it is better
|  than this as it allows you to set the size where you can't at present,
|  nor with this patch.
Oops, this is going into an entirely wrong direction! The posting is not about patches, 
it presented a strategy for discussion, and sums up an extract of the reading I have been
stuck with for a couple of days. 
Frankly, I am really sorry that this should evolve into a discussion regarding whose patches
are better - such was never my intention. You have put in a lot of work into these patches,
despite having other work to do, and this in itself really is very commendable.

Lastly, can you please go back one posting and look through said patch - it does not
even touch the default settings you are mentioning; all it does is removing the PACKET_SIZE
socket option. This is the code I am actually using myself and have sent it as an aid; since
it is now decoupled from other issues (please do have a look).
 
Sorry, I was not able to produce the full works, reading up on this fixed `s' issue and
resolving the contradictory statements in RFC 3448/4340/4342 (plus CCID 4 draft) ate away
a lot of time that could have been spent implementing.

I further understand that you are working on the CCID-3 code and therefore wanted to
bring up the strategy/discussion first. 

What I am currently working on is tidying up the general socket API. This involves:
  * default fallback service code   [done]
  * removing the PACKET_SIZE option [this discussion/posting]
  * setting the CCIDs via socket option and poll the actual CCID via getsockopt [tbd]
  * fitting partial-checksum coverage into the code [in progress]
  * any other reasonable suggestions which may help getting application programming started
    [since: no stable API --> no coherent API documentation --> no application programs]

Once this is wrapped up I intend to update the documentation on the API, in form of a `DCCP
socket programming mini HowTo', to be put online or added to the existing documentation.
With the help of constructive discussion this may happen. 


To summarise:
-------------
1) The real problem is not in patches - RFC 4340..2 are elusive and in parts outright wrong
   about assumptions on the packet size. Substantial evidence that for instance using MSS
   as fixed `s' is detrimental was provided in the last posting. 
2) Weighted average was introduced as a strategy to resolve this in an implementable format.
3) Can we reach agreement regarding that PACKET_SIZE option does not help with the `fixed s'
   issue and therefore it is OK to remove it???
4) Literature research as per previous posting prevented coming up with patch. If you would
   rather not work on it and no one else is interested, I will try to find some free time. 

-Gerrit
