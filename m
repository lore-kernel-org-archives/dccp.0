From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 07 Nov 2007 17:50:07 +0000
Subject: Re: [PATCH 5/9] [CCID2]: Replace pipe assignment-function with assignment
Message-Id: <5640c7e00711070950j44afcke497c40ed64a2c8d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.49880@strip-the-willow>
In-Reply-To: <200711031323.49880@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> The function ccid2_change_pipe only does an assignment. This patch simplifies the code by
> replacing the function with the assignment it performs.
>
> Furthermore, the type of pipe is promoted from `signed' to unsigned (increasing the range).
> As a result, a BUG_ON test for negative values now becomes obsolete (for safety not removed,
> but replaced with a less annoying `DCCP_BUG').
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
