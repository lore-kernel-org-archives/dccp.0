From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 13:05:35 +0000
Subject: Re: [PATCH 10/10]: Simplify dccp_rcv_state_process
Message-Id: <200611271305.36045@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611241620.18283@strip-the-willow>
In-Reply-To: <200611241620.18283@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [DCCP]: Simplify dccp_rcv_state_process
|  >
|  > This patch does not change the algorithm, it just simplifies control flow a bit.
|  >
|  > The main changes are:
|  >  * cleanup after dccp_rcv_request_sent_state_process is now done within that function,
|  >    not in dccp_rcv_state_process
|  >  * as a result the control flow in dccp_rcv_request becomes a bit simpler
|  
|  Gerrit, this one I have mixed feelings, as the simplification seems
|  OK, but the principle of staying as close to the TCP counterpart
|  (tcp_rcv_synsent_state_process) was the reason for me to leave parts
|  of the cleanup to the caller,
Ok. Please then disregard this patch; I have removed it from 

http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/

The other patches were brought up-to-date with regard to your and Ian's comments, including
Signed-off/Acked-by lines where provided.

Many thanks
Gerrit
