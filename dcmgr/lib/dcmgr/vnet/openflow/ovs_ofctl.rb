# -*- coding: utf-8 -*-

module Dcmgr
  module VNet
    module OpenFlow

      class OvsOfctl
        include Dcmgr::Logger
        attr_accessor :ovs_ofctl
        attr_accessor :verbose
        attr_accessor :switch_name

        def initialize config
          # TODO: Make ovs_vsctl use a real config option.
          @ovs_ofctl = config.ovs_ofctl_path
          @ovs_vsctl = config.ovs_ofctl_path.dup
          @ovs_vsctl[/ovs-ofctl/] = 'ovs-vsctl'

          @verbose = config.verbose_openflow
        end

        def get_bridge_name datapath_id
          command = "#{@ovs_vsctl} --no-heading -- --columns=name find bridge datapath_id=%016x" % datapath_id
          puts command if verbose == true
          /^"(.*)"/.match(`#{command}`)[1]
        end

        def add_flow flow
          command = "#{@ovs_ofctl} add-flow #{switch_name} #{flow.match_to_s},actions=#{flow.actions_to_s}"
          logger.debug "'#{command}' => #{system(command)}."
        end

        def add_flows_from_list flows
          recmds = []

          eos = "__EOS_#{Isono::Util.gen_id}___"
          recmds << "#{@ovs_ofctl} add-flow #{switch_name} - <<'#{eos}'"
          flows.each { |flow|
            full_flow = "#{flow.match_to_s},actions=#{flow.actions_to_s}"
            puts "ovs-ofctl add-flow #{switch_name} #{full_flow}" if verbose == true
            recmds << full_flow
          }
          recmds << "#{eos}"

          logger.debug("applying flow(s): #{recmds.size - 2}")
          system(recmds.join("\n"))
        end

        def add_flood_flows_from_list flows, args
          recmds = []

          eos = "__EOS_#{Isono::Util.gen_id}___"
          recmds << "#{@ovs_ofctl} add-flow #{switch_name} - <<'#{eos}'"
          flows.each { |flow|
            full_flow = "#{flow.match_to_s},actions=#{flow.flood_actions_to_s(args)}"
            puts "ovs-ofctl add-flow #{switch_name} #{full_flow}" if verbose == true
            recmds << full_flow
          }
          recmds << "#{eos}"

          logger.debug("applying flow(s): #{recmds.size - 2}")
          system(recmds.join("\n"))
        end

        def del_flows_from_list flows
          recmds = []

          eos = "__EOS_#{Isono::Util.gen_id}___"
          recmds << "#{@ovs_ofctl} del-flows #{switch_name} - <<'#{eos}'"
          flows.each { |flow|
            full_flow = "#{flow.match_sparse_to_s}"
            puts "ovs-ofctl del-flow #{switch_name} #{full_flow}" if verbose == true
            recmds << full_flow
          }
          recmds << "#{eos}"

          logger.debug("removing flow(s): #{recmds.size - 2}")
          system(recmds.join("\n"))
        end

        def add_gre_tunnel tunnel_name, remote_ip, key
          system("#{@ovs_vsctl} add-port #{switch_name} #{tunnel_name} -- set interface #{tunnel_name} type=gre options:remote_ip=#{remote_ip} options:key=#{key}")
        end

      end

    end
  end
end
