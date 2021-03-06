package io.rackshift.metal.sdk.util;

import io.rackshift.metal.sdk.model.Ip;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.net.util.SubnetUtils;
import org.springframework.util.CollectionUtils;

import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.Pattern;

public class IpUtil {
    private static final int TIME_OUT = 3000;

    public static List<String> getIpRange(String startIp, String endIp, String gateway, String mask) {
        List<String> result = new ArrayList<>();
        SubnetUtils utils = new SubnetUtils(gateway, mask);
        SubnetUtils.SubnetInfo info = utils.getInfo();
        String[] allIps = info.getAllAddresses();
        for (String allIp : allIps) {
            if (ipInRange(allIp, startIp, endIp)) {
                result.add(allIp);
            }
        }
        return result;
    }

    private static Boolean ipInRange(String ip, String startIp, String endIp) {
        String ipSection = startIp + "-" + endIp;
        ip = ip.trim();
        final String REGX_IP = "((25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]\\d|\\d)\\.){3}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]\\d|\\d)";
        final String REGX_IPB = REGX_IP + "\\-" + REGX_IP;
        if (!ipSection.matches(REGX_IPB) || !ip.matches(REGX_IP))
            return false;
        int idx = ipSection.indexOf('-');
        String[] sips = ipSection.substring(0, idx).split("\\.");
        String[] sipe = ipSection.substring(idx + 1).split("\\.");
        String[] sipt = ip.split("\\.");
        long ips = 0L, ipe = 0L, ipt = 0L;
        for (int i = 0; i < 4; ++i) {
            ips = ips << 8 | Integer.parseInt(sips[i]);
            ipe = ipe << 8 | Integer.parseInt(sipe[i]);
            ipt = ipt << 8 | Integer.parseInt(sipt[i]);
        }
        if (ips > ipe) {
            long t = ips;
            ips = ipe;
            ipe = t;
        }
        return ips <= ipt && ipt <= ipe;
    }

    public static Ip getConnectableIp(List<Ip> ips) {
        if (CollectionUtils.isEmpty(ips)) {
            return null;
        }
        //??????????????????
        Collections.shuffle(ips);
        for (Ip ip : ips) {
            try {
                //??????????????????IP
                if (!InetAddress.getByName(ip.getIp()).isReachable(TIME_OUT)) {
                    return ip;
                }
            } catch (IOException ignore) {
                //????????????
            }
        }

        return null;
    }

    static Pattern ipPattern = Pattern
            .compile("^((\\d|[1-9]\\d|1\\d\\d|2[0-4]\\d|25[0-5]"
                    + "|[*])\\.){3}(\\d|[1-9]\\d|1\\d\\d|2[0-4]\\d|25[0-5]|[*])$");

    public static boolean checkIP(String str) {
        return ipPattern.matcher(str).matches();
    }

    public static boolean ping(String ip) {
        if (StringUtils.isAnyBlank(ip)) {
            throw new RuntimeException("??????ping??????????????????????????????");
        }
        try {
            InetAddress address = Inet4Address.getByName(ip);
            return address.isReachable(1500);
        } catch (Exception e) {
            return false;
        }
    }


    /**
     * ?????????icmp ?????????????????????socket??????443??????????????????????????????true
     * ??????????????????????????????icmp??????
     *
     * @param ip
     * @return
     */
    public static boolean canConnect(String ip) {
        if (StringUtils.isAnyBlank(ip)) {
            throw new RuntimeException("??????ping??????????????????????????????");
        }
        Socket s = null;
        try {
            InetAddress address = Inet4Address.getByName(ip);
            if (address.isReachable(1500)) return true;
            s = new Socket();
            s.connect(new InetSocketAddress(ip, 443));
        } catch (Exception e) {
            return false;
        } finally {
            if (s != null) {
                try {
                    s.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        return true;
    }

}
