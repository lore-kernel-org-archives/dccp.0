From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 06 Nov 2007 17:22:29 +0000
Subject: Re: [PATCH 4/9] [CCID2]: Replace cwnd assignment-function with assignment
Message-Id: <5640c7e00711060922r1a978714w55a5d7341a317455@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.46788@strip-the-willow>
In-Reply-To: <200711031323.46788@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> The current function ccid2_change_cwnd in effect makes only an assignment, as
> the test whether cwnd has reached 0 is only required when cwnd is halved.
>
> This patch simplifies the code by replacing the function with the assignment
> it performs.
>
> Furthermore, since ssthresh derives from cwnd and appears in many assignments and
> comparisons, the type of ssthresh has also been changed to match that of cwnd.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
