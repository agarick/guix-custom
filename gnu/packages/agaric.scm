(define-module (gnu packages agaric)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages glib) ; libgestures
  #:use-module (gnu packages serialization) ; libgestures
  #:use-module (gnu packages xorg) ; xf86-input-cmt
  )

(define-public xf86-input-cmt
  (package
   (name "xf86-input-cmt")
   (version "711bbcd2dfd67ccdf635ff41d177f1ed1f755bd4")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/hugegreenbug/xf86-input-cmt.git")
	   (commit version)))
     (sha256 (base32 "162y8v87b9xvv1zk6vj0flx8kpg91n0k9rckjf279imvyy7hz6nw"))))
   (build-system gnu-build-system)
   (native-inputs
    `(("pkg-config" ,pkg-config)))
   (inputs
    `(("libevdevc" ,my-libevdevc)
      ("libgestures" ,my-libgestures)
      ("xorg-server" ,xorg-server)
      ("xorgproto" ,xorgproto)))
   (arguments
    `(#:configure-flags
      (list (string-append "--with-sdkdir="
			   %output
			   "/include/xorg"))
      #:phases (modify-phases %standard-phases
      (add-after 'unpack 'fix-deps
        (lambda* (#:key inputs #:allow-other-keys)
          (let ((evd (assoc-ref inputs "libevdevc"))
                (ges (assoc-ref inputs "libgestures")))
            (setenv "C_INCLUDE_PATH"
                    (string-append
                      (getenv "C_INCLUDE_PATH") ":" evd "/include:" ges "/usr/include"))
            (setenv "LIBRARY_PATH"
                    (string-append
                      (getenv "LIBRARY_PATH") ":" evd "/usr/lib:" ges "/usr/lib"))
            #t))))))
   (home-page "https://github.com/hugegreenbug/xf86-input-cmt")
   (synopsis "chromiumos touchpad driver for linux")
   (description "chromiumos touchpad driver for linux")
   (license license:bsd-3)))

(define-public libevdevc
  (package
   (name "libevdevc")
   (version "05f67cb94888f3d9f97b5557caf4081543e8ba0e")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/hugegreenbug/libevdevc.git")
	   (commit version)))
     (sha256 (base32 "0jnjyzh5ncdal6f125q4i5k6s7pd6ca3yha92d5prqfganlr3apd"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases (modify-phases %standard-phases
                 (replace 'configure
                   (lambda* (#:key outputs #:allow-other-keys)
                     (substitute* "common.mk"
                       (("/bin/echo") (which "echo")))
                     (substitute* "include/module.mk"
                       (("\\$\\(DESTDIR\\)/usr/")
			(string-append (assoc-ref outputs "out") "/")))
                     (substitute* "src/module.mk"
                       (("\\$\\(DESTDIR\\)")
			(string-append (assoc-ref outputs "out") "/"))))))))
   (home-page "https://github.com/hugegreenbug/libevdevc")
   (synopsis "chromiumos libevdev for linux")
   (description "chromiumos libevdev for linux")
   (license license:bsd-3)))

(define-public libgestures
  (package
   (name "libgestures")
   (version "7a91f7cba9f0c5b6abde2f2b887bb7c6b70a6245")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/hugegreenbug/libgestures.git")
	   (commit version)))
     (sha256 (base32 "03wg0jqh9ilsr9vvqmakg4dxf3x295ap2sbq7gax128vgylb79i7"))))
   (build-system gnu-build-system)
   (native-inputs
    `(("glib" ,glib)
      ("pkg-config" ,pkg-config)))
   (inputs
    `(("jsoncpp" ,jsoncpp)))
   (arguments
    `(#:tests? #f
      #:phases (modify-phases %standard-phases
                 (replace 'configure
                   (lambda* (#:key outputs #:allow-other-keys)
                            (substitute* "Makefile"
                                         (("DESTDIR = ")
                                          (string-append "DESTDIR = " (assoc-ref outputs "out"))))
                            (substitute* "include/gestures/include/finger_metrics.h"
                                         (("vector.h\"") "vector.h\"\n#include <math.h>")))))))
   (home-page "https://github.com/hugegreenbug/libgestures")
   (synopsis "chromiumos libgestures for linux")
   (description "chromiumos libgestures for linux")
   (license license:bsd-3)))

(define-public qt5ct
  (package
   (name "qt5ct")
   (version "0.35")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "mirror://sourceforge/qt5ct/qt5ct-" version ".tar.bz2"))
     (sha256 (base32 "0xzgd12cvm4vyzl8qax6izdmaf46bf18h055z6k178s8pybm1sqw"))))
   (build-system gnu-build-system)
   (inputs
    `(("qt" ,qt)
      ("qtsvg" ,qtsvg)))
   ;(arguments
   ; `(#:phases (alist-cons-after
   ;             'unpack 'fix-docdir
   ;             (lambda _
   ;               ;; Although indent uses a modern autoconf in which docdir
   ;               ;; defaults to PREFIX/share/doc, the doc/Makefile.am
   ;               ;; overrides this to be in PREFIX/doc.  Fix this.
   ;               (substitute* "doc/Makefile.in"
   ;                 (("^docdir = .*$") "docdir = @docdir@\n")))
   ;             %standard-phases)))
   (synopsis "Qt5 Configuration Tool")
   (description "This program allows users to configure Qt5 settings (theme, font, icons, etc.) under DE/WM without Qt integration.")
   (license license:bsd)
   (home-page "https://qt5ct.sourceforge.io/")))
