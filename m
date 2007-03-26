From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 26 Mar 2007 02:41:33 +0000
Subject: Re: [PATCH 4/25]: Cheaper & smaller timestamping
Message-Id: <5640c7e00703251941k60730744m7d026eb8fdd998c8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.22972@strip-the-willow>
In-Reply-To: <200703211844.22972@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/22/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Cheaper & smaller timestamping
>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

A couple of comments though:
- this is how I had the code originally in many cases and Arnaldo
changed - can't remember why.
- we should be looking at using the new ktime as monotonic but that
can be a task for another time.
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
