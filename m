From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 25 Oct 2007 10:29:25 +0000
Subject: Re: Gstreamer e DCCP: issues related to ccid-3
Message-Id: <200710251129.25237@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
In-Reply-To: <5bc4c4570710242047h1d9b1c64k6381ba5c3a421355@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  Basically the functions that I'm using to send are the following:
| =20
|  PS: the second function, gst_dccp_send_buffer, is a call back function
|  called by gstreamer when it has data to be sent. Thank you.
 =20
|  /* write buffer to given socket incrementally.
|  =A0* Returns number of bytes written.
|  =A0*/
|  gint
|  gst_dccp_socket_write (int socket, const void *buf, size_t count)
|  {
|  =A0size_t bytes_written =3D 0;
|  =A0ssize_t wrote;
| =20
|  =A0while (bytes_written < count) {
|  =A0 =A0wrote =3D send (socket, (const char *) buf + bytes_written,
|  =A0 =A0 =A0 =A0 =A0 =A0count - bytes_written, MSG_NOSIGNAL);
|  =A0 =A0if (wrote <=3D 0) {
|  =A0 =A0 =A0return bytes_written;
|  =A0 =A0}
|  =A0 =A0bytes_written +=3D wrote;
|  =A0}
/* something like (but do have a look at the paraslash sources)
    do {
	wrote =3D send (socket, (const char *) buf + bytes_written,
                             count - bytes_written, MSG_NOSIGNAL);
    }  while (wrote < 0 && errno =3D EAGAIN);
*/


If the function below is a callback, then this may be tricky, since
the solution is to poll (the above do..while loop), until there is=20
room in the sender's TX queue.
In principle, you could use the same do..while loop, or decide to
store the chunk back into a list and reschedule the callback to
"call later", as it is done in the paraslash sources.
=20
| =20
|  /* write a GDP header to the socket. =A0Return false if fails. */
|  GstFlowReturn
|  gst_dccp_send_buffer (GstElement * this, GstBuffer * buffer, int socket)
|  {
|  =A0size_t wrote;
| =20
|  =A0gint size =3D 0;
|  =A0guint8 *data;
| =20
|  =A0size =3D GST_BUFFER_SIZE (buffer);
|  =A0data =3D GST_BUFFER_DATA (buffer);
| =20
|  =A0GST_LOG_OBJECT (this, "writing %d bytes for GDP buffer header\n", siz=
e);
|  =A0printf("writing %d bytes for GDP buffer header\n\n", size);
|  =A0wrote =3D gst_dccp_socket_write (socket, data, size);
|  =A0//g_free (data);
| =20
|  =A0if (wrote !=3D size) {
|  =A0 =A0GST_ELEMENT_ERROR (this, CORE, TOO_LAZY, (NULL),
|  =A0 =A0 =A0 =A0("Error while sending data"));
|  =A0 =A0printf("Error while sending data\n");
|  =A0 =A0return GST_FLOW_ERROR;
|  =A0}
| =20
|  =A0return GST_FLOW_OK;
|  }
| =20
