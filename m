From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 19:41:27 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611281941.28068@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [DCCP]: Use `unsigned' for packet lengths
|  >
|  I'm wondering whether this code is 64 bit safe??? I don't think it is.
|  Arnaldo can probably advise.
|  
|  We changed int to u32 for length and I went and checked the callers
|  and parameters. They all basically go back to skb->len which is an
|  unsigned int. So at least we did the right thing changing to unsigned
|  as we were mismatched before.
|  
|  As much as I would like to change sk_buff definition to __u32 and save
|  2 bytes on 64 bit I don't think we can really as that is in a
|  userspace include as I understand it and therefore we would break
|  programs...
These are further changes - do you think that this would improve anything - I don't know.
The proposed change of u32 for payload length seems fully sufficient in my eyes since 
with that we have more than enough for IPv4 and in IPv6 we are already in jumbogram-dimensions.

I have two other suggestions regarding 64-bit unsigned - I think it would make sense to store
the calculated send rate in bytes per microsecond, since there are some nasty conversion problems
attached to it, as well as division errors. I am working on this right now.
