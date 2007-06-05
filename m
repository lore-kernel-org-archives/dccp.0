From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Jun 2007 13:58:48 +0000
Subject: Re: [PATCH 0/3] DCCP: Minor changes
Message-Id: <200706051458.49003@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706041149.01701.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200706041149.01701.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I think it will still be easier rebasing your patch set on these than the tree
|  without them as you were relying on a form of them previously.
Meanwhile yes. They used to be based on your patches, then I rewrote them at
the long-ago date of last submission, now they are standalone, will rewrite them
again as soon as the changes come through.


|  As far as other patches go I don't have any at present. 
|  I'm thinking of doing some dccp_probe patches to track changes in tcp_probe but
|  haven't done these yet and they would be well away from the other
|  changes and not conflict probably.
That would be good - I have updated my patchset also to use the newer ktime_t
interface. I have one idea/suggestion for dccp_probe from my todo list:
often the output is large and consumes a lot of processing power/time to just
output many lines. Is there any point in adding a module parameter, e.g.
`threshold', which only prints every X or Y timepoints? As a sketch,


static int threshold = 0;
module_param(int, threshold);

static atomic_t rate_limit;

/* a primitive form of rate-limiting the output to /proc/dccpprobe */
if (threshold && atomic_inc(&rate_limit) > threshold) {
 threshold = 0;
 // ...
}

I've had these notes for three months and never got round to them!
