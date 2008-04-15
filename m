From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 15 Apr 2008 15:21:13 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
Message-Id: <20080415152113.GB20735@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| | What happens if application is compiled with dccp_packet_info containing only 
| | one field (priority) and kernel containing two fields (for example priority 
| | and later added expiry time)? Wouldn't that implementation make extensions to 
| | dccp_packet_info impossible?
| Had not looked at it from this point of view. So you are suggesting
| 
| 	if (msg->msg_control != NULL && msg->msg_controllen >= sizeof(*dcp))
| 		dcp = (struct dccp_packet_info *)msg->msg_control;
| 
| instead? Agreed, point #1 to change in the patch.
| 
No, the above is nonsense. If the application uses an earlier version of the API, then
it needs to be recompiled, there is no way it could pretend to have an adequate size.

So my take is that still the '=' is correct. But maybe this is a known problem?


The University of Aberdeen is a charity registered in Scotland, No SC013683.

