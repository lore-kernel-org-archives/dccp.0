From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 18 Aug 2008 15:14:07 +0000
Subject: Re: [PATCH] DCCP: Fix to handle invalid packets in REQUEST state
Message-Id: <20080818151407.GA3640@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <488FF324.6050706@cn.fujitsu.com>
In-Reply-To: <488FF324.6050706@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Yes, it does, the last Reset (no connection) will cause client entering  
> TIMEWAIT state. Your patch is correct.
Thanks a lot for testing, this is much appreciated. I have put some more work in and
reviewed the concept. I will submit the patch and update the test tree.

Thanks again 
Gerrit
