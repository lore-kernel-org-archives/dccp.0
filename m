From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 08:10:41 +0000
Subject: Re: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200612010810.41810@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611301318.46685@strip-the-willow>
In-Reply-To: <200611301318.46685@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Lars Eggert:
|  On Nov 30, 2006, at 11:13, Ian McDonald wrote:
|  > This patch provides a configuration option to set the bound for the
|  > nofeedback timer, using as default the TCP RTO timeout of 1 second.
|  
|  The default TCP RTO is 3 seconds (RFC 2988). Linux is apparently not  
|  conformant to that RFC?
Ian didn't copy the remainder of the mail, which had the clarifying explanation
that this setting is related to section 2.4 of RFC 2988:
  (2.4) "Whenever RTO is computed, if it is less than 1 second then the
         RTO SHOULD be rounded up to 1 second."

Also [RFC 3448, sec. 1]: 
  "Another possibility would be to set t_RTO = max(4R, one second), 
   to match the recommended minimum of one second on the RTO [5]." 
   where [5] = RFC 2988.

Currently, the nofeedback timer is set to 

  t_nfb = max(4 * R, 2*s/X)

When R is very small (e.g. 250 usec), 4 * R is close to the dimension of one or
two clock ticks.
