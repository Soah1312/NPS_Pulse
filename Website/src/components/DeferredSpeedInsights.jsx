import { useEffect, useState } from 'react';

export default function DeferredSpeedInsights() {
  const [SpeedInsightsComponent, setSpeedInsightsComponent] = useState(null);

  useEffect(() => {
    if (!import.meta.env.PROD) return;

    let isMounted = true;

    import('@vercel/speed-insights/react').then((mod) => {
      if (isMounted) {
        setSpeedInsightsComponent(() => mod.SpeedInsights);
      }
    });

    return () => {
      isMounted = false;
    };
  }, []);

  if (!SpeedInsightsComponent) return null;

  return <SpeedInsightsComponent />;
}
