"use client";

import { ElementType, ReactNode, useEffect, useRef } from "react";

type RevealProps = {
  children: ReactNode;
  className?: string;
  delay?: number;
  as?: ElementType;
};

export function Reveal({
  children,
  className = "",
  delay = 0,
  as: Component = "div"
}: RevealProps) {
  const ref = useRef<HTMLElement | null>(null);

  useEffect(() => {
    const node = ref.current;
    if (!node) {
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
          } else if (entry.boundingClientRect.top > 0) {
            entry.target.classList.remove("is-visible");
          }
        });
      },
      {
        threshold: 0.16,
        rootMargin: "0px 0px -10% 0px"
      }
    );

    observer.observe(node);

    return () => observer.disconnect();
  }, []);

  return (
    <Component
      ref={ref}
      className={`scroll-reveal ${className}`.trim()}
      style={{ transitionDelay: `${delay}ms` }}
    >
      {children}
    </Component>
  );
}
