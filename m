From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 25 Nov 2007 17:24:18 +0000
Subject: Re: Passive-close patches
Message-Id: <20071125172418.GA6678@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After further analysis, I think that the way passive-close was implemented 
by the patches (using intermediate states) is the cleanest (and maybe the
simplest solution). 

It would be nice if it worked with the present approach of just enqueueing 
via dccp_fin, but several demands make a simple solution very difficult:

 * passive-close can be a received Close (server holds timewait state) or
   a received CloseReq (which is what the current code supports);
 * the code needs to interact correctly with the inet_stream socket implementation,
   in particular inet_stream_connect (must not enter DCCP_CLOSED too early) and inet_accept();
 * the application may not even read the queue (bug, programming error, program suspended etc.).

In a previous discussion with Ian the question of a simpler solution also came up; Ian also tried
to find a more simple solution. After several days of thinking this over, it seems that a simpler
solution is not possible. 

Thus, the state of this is:

 * documentation has been revised and uploaded to (this includes the test program)
   http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/

 * I am revising this patch set; the leaked-skb issue has been fixed, I am currently testing the
   patch and will resubmit it


---------------------------------------------------------------------------------------------------
For the record, I have found my old notes which identified the two problems leading to this patch:

  1.) The first problem lies in using inet_stream_connect():

  An absurd case arises if we let the protocol machinery, not the application,
  go through the states. If the protocol machinery allows to proceed to DCCP_CLOSED
  (which corresponds to TCP_CLOSE), connect() returns with -ECONNABORTED, even if
  there was data in the receive queue. 
  
  Therefore, if we want to keep the useful abstraction of inet_stream_connect(), we
  need to make sure that a passive close can not lead to DCCP_CLOSED via the protocol
  machinery alone. 
  
  2.) The second problem is also related to entering DCCP_CLOSED too early: 
  
  Even if connect() were fixed, if a passive-close can directly trigger a state 
  transition from OPEN to DCCP_CLOSED, the receiver may not be able to read data
  from its input queue. The reason is that DCCP_CLOSED state has been entered while
  the SOCK_DONE flag has not yet been set.  Consequently, any subsequent call to 
  dccp_recvmsg() terminates in -ENOTCONN, despite of a potentially full receive queue.
---------------------------------------------------------------------------------------------------
