From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 19 Dec 2006 21:57:43 +0000
Subject: Re: [PATCH 5/8]: Move debugging macro to header file
Message-Id: <39e6f6c70612191357u223a9a71g6e8856cae809791f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
In-Reply-To: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/19/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> Gerrit,
>
> From memory it is when I do make modules_install that it fails as it
> is a linking issue not a compiling issue. The relevant part of the
> config is that I've got CCID3 debugging turned on of course.

The loop comes because dccp_ccid3.ko needs symbols provided by
dccp_tfrc_lib.ko, so if we try to export ccid3_pr_debug to be used by
dccp_tfrc_lib.ko we'll get the loop, so I guess the right thing to do
is to introduce tfrc_pr_debug, that will give us more flexibility,
allowing one to select ccid3 debugging, tfrc debugging, both or none.

- Arnaldo
